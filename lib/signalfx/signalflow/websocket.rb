# Copyright (C) 2017 SignalFx, Inc. All rights reserved.

require 'json'
require 'thread'
require 'faye/websocket'

require_relative './binary'
require_relative './channel'
require_relative './computation'

class WebsocketError < StandardError
  def initialize(ws_err)
    super ws_err.message
  end
end


# A WebSocket transport for SignalFlow.  This should not be used directly by
# end-users.
class SignalFlowWebsocketTransport
  DETACHED = "DETACHED"

  # A lower bound on the amount of time to wait for a computation to start
  COMPUTATION_START_TIMEOUT_SECONDS = 30

  def initialize(api_token, stream_endpoint, proxy_url: nil, logger: Logger.new(STDOUT, progname: "signalfx"), debug: false)
    @api_token = api_token
    @stream_endpoint = stream_endpoint
    @logger = logger
    @compress = true
    @proxy_url = proxy_url
    @debug = debug

    @lock = Mutex.new
    @close_reason = nil
    @last_error = nil
    reinit
  end

  def reinit
    @ws = nil
    @authenticated = false
    @chan_callbacks = {}

    name_lock = Mutex.new
    num = 0
    # Returns a unique channel name each time it is called
    @channel_namer = ->{
      name_lock.synchronize do
        num += 1
        "channel-#{num}"
      end
    }
  end
  private :reinit

  # Starts a job (either execute or preflight) and waits until the JOB_START
  # message is received with the computation handle arrives so that we can
  # create a properly initialized computation object.  Yields to the given
  # block which should send the WS message to start the job.
  def start_job
    computation = nil

    channel = make_new_channel

    yield channel.name

    while true
      begin
        msg = channel.pop(COMPUTATION_START_TIMEOUT_SECONDS)
      rescue ChannelTimeout
        raise "Computation did not start after at least #{COMPUTATION_START_TIMEOUT_SECONDS} seconds"
      end
      if msg[:type] == "error"
        raise ComputationFailure.new(msg[:message])
      end

      # STREAM_START comes before this but contains no useful information
      if msg[:event] == "JOB_START"
        computation = Computation.new(msg[:handle], method(:attach), method(:stop))
        computation.channel = channel
      elsif msg[:type] == "computation-started"
        computation = Computation.new(msg[:computationId], method(:attach), method(:stop))
        # Start jobs only use the channel to get error messages and can
        # detach from the channel once the job has started.
        channel.detach
      else
        next
      end

      return computation
    end
  end

  def execute(program, start: nil, stop: nil, resolution: nil, max_delay: nil, persistent: nil, immediate: false)
    start_job do |channel_name|
      send_msg({
        :type => "execute",
        :channel => channel_name,
        :program => program,
        :start => start,
        :stop => stop,
        :resolution => resolution,
        :max_delay => max_delay,
        :persistent => persistent,
        :immediate => immediate,
        :compress => @compress,
      }.reject!{|k,v| v.nil?}.to_json)
    end
  end

  def preflight(program, start, stop, resolution: nil, max_delay: nil)
    start_job do |channel_name|
      send_msg({
        :type => "preflight",
        :channel => channel_name,
        :program => program,
        :start => start,
        :stop => stop,
        :resolution => resolution,
        :max_delay => max_delay,
        :compress => @compress,
      }.reject!{|k,v| v.nil?}.to_json)
    end
  end

  def start(program, start: nil, stop: nil, resolution: nil, max_delay: nil)
    start_job do |channel_name|
      send_msg({
        :type => "start",
        :channel => channel_name,
        :program => program,
        :start => start,
        :stop => stop,
        :resolution => resolution,
        :max_delay => max_delay,
      }.reject!{|k,v| v.nil?}.to_json)
    end
  end

  def stop(handle, reason)
    send_msg({
      :type => "stop",
      :handle => handle,
      :reason => reason,
    }.reject!{|k,v| v.nil?}.to_json)
  end

  # This doesn't actually work on the backend yet
  def attach(handle, filters: nil, resolution: nil)
    channel = make_new_channel

    send_msg({
      :type => "attach",
      :channel => channel.name,
      :handle => handle,
      :filters => filters,
      :resolution => resolution,
      :compress => @compress,
    }.reject!{|k,v| v.nil?}.to_json)

    channel
  end

  def detach(channel, reason=nil)
    send_msg({
      :type => "detach",
      :channel => channel,
      :reason => reason,
    }.to_json)

    # There is no response message from the server signifying detach complete
    # and there could be messages coming in even after the detach request is
    # sent.  Therefore, use a sentinal value in place of the callback block so
    # that the message receiver logic can distinguish this case from some
    # anomolous case (say, due to bad logic in the code).
    @chan_callbacks[channel] = DETACHED
  end

  def close
    if @ws
      @ws.close
    end
  end

  def send_msg(msg)
    @lock.synchronize do
      if @ws.nil?
        startup_client

        # Polling is the simplest and most robust way to handle blocking until
        # authenticated. Using ConditionVariable requires more complex logic
        # that gains very little in terms of efficiecy given how quick auth
        # should be.
        start_time = Time.now
        while !@authenticated
          # The socket will be closed by the server if auth isn't successful
          # within 5 seconds so no point in waiting longer
          if Time.now - start_time > 5 || @close_reason
            if @last_error
              raise WebsocketError.new(@last_error)
            end
            raise "Could not authenticate to SignalFlow WebSocket: #{@close_reason}"
          end
          sleep 0.1
        end
      end

      @ws.send(msg)
    end
  end
  private :send_msg

  def on_close(msg)
    if @debug
      @logger.info("Websocket on_close: #{msg}")
    end

    @close_reason = "(#{msg.code}, #{msg.reason})"
    @chan_callbacks.keys.each do |channel_name|
      invoke_callback_for_channel({ :event => "CONNECTION_CLOSED" }, channel_name)
    end

    reinit
  end

  def on_error(e)
    @logger.error("ERROR #{e.inspect}")
    @last_error = e
  end


  def on_message(m)
    if @debug
      @logger.info("Websocket on_message: #{m}")
    end

    is_text = m.data.kind_of?(String)

    begin
      message_received(m.data, is_text)
    rescue Exception => e
      @logger.error("Error processing SignalFlow message: #{e.backtrace.first}: #{e.message} (#{e.class})")
    end
  end

  def on_open
    if @debug
      @logger.info("Websocket on_open")
    end

    @ws.send({
      :type => "authenticate",
      :token => @api_token,
    }.to_json)
  end

  # Start up a new WS client in its own thread that runs an EventMachine
  # reactor.
  def startup_client
    this = self

    options = {
      :tls => {
        :verify_peer => true,
      }
    }
    if @proxy_url
      options[:proxy] = {
       :origin  => @proxy_url,
      }
    end
    Thread.new {
      EM.run {
        @ws = Faye::WebSocket::Client.new("#{@stream_endpoint}/v2/signalflow/connect", [], options)
        @ws.on :error do |e|
          this.on_error(e)
        end

        @ws.on :close do |e|
          this.on_close(e)
          EM.stop_event_loop
        end

        @ws.on :message do |m|
          this.on_message(m)
        end

        @ws.on :open do
          this.on_open
        end
      }
    }
  end
  private :startup_client

  def invoke_callback_for_channel(msg, channel_name)
    chan = @chan_callbacks[channel_name]

    raise "Callback for channel #{channel_name} is missing!" unless chan

    if chan == DETACHED
      return
    else
      chan.inject_message(msg)
    end
  end
  private :invoke_callback_for_channel

  def message_received(raw_msg, is_text)
    msg = add_parsed_timestamp!(parse_message(raw_msg, is_text))

    if msg[:type] == "authenticated"
      @authenticated = true
      return
    end

    if msg[:channel]
      invoke_callback_for_channel(msg, msg[:channel])
    else
      # Ignore keep-alives
      if msg[:event] == "KEEP_ALIVE"
        return
      else
        raise "Unknown SignalFlow message: #{msg}"
      end
    end
  end
  private :message_received

  def parse_message(raw_msg, is_text)
    if is_text
      JSON.parse(raw_msg, {:symbolize_names => true})
    else
      # Convert the byte array to a string
      BinaryMessageParser.parse(raw_msg.pack("c*"))
    end
  end
  private :parse_message

  def add_parsed_timestamp!(msg)
    if msg.has_key?(:timestampMs)
      msg[:timestamp] = Time.at(msg[:timestampMs] / 1000.0)
    end
    msg
  end
  private :add_parsed_timestamp!

  def make_new_channel
    name = @channel_namer.()
    channel = Channel.new(name, ->(){ detach(name) })
    @chan_callbacks[name] = channel
    channel
  end
  private :make_new_channel
end
