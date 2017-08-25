require 'json'
require 'thread'
require 'websocket-client-simple'
require 'eventmachine'

require_relative './binary'
require_relative './channel'
require_relative './computation'


class SignalFlowWebsocketTransport
  DETACHED = "DETACHED"

  def initialize(api_token, stream_endpoint)
    @api_token = api_token
    @stream_endpoint = stream_endpoint
    @compress = true

    @lock = Mutex.new
    @close_reason = nil
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
    lock = Mutex.new
    job_started_cv = ConditionVariable.new
    computation = nil

    channel = make_new_channel
    channel.each_message_async do |msg, detach|
      if msg[:event] == "JOB_START"
        computation = Computation.new(msg[:handle], method(:attach), method(:stop))
        channel.computation = computation
        computation.channel = channel
        lock.synchronize do
          job_started_cv.signal
        end
      end
    end

    yield channel.name

    lock.synchronize do
      if computation.nil?
        timeout = 20
        job_started_cv.wait(lock, timeout)
        if computation.nil?
          raise "Computation did not start within #{timeout} seconds"
        end
      end
    end

    computation
  end

  def execute(program, start: nil, stop: nil, resolution: nil, max_delay: nil, persistent: nil)
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
    send_msg({
      :type => "start",
      :program => program,
      :start => start,
      :stop => stop,
      :resolution => resolution,
      :max_delay => max_delay,
    }.reject!{|k,v| v.nil?}.to_json)
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
    @close_reason = "(#{msg.code}, #{msg.data})"
    @chan_callbacks.keys.each do |channel_name|
      invoke_callback_for_channel({ :event => "CONNECTION_CLOSED" }, channel_name)
    end

    reinit
  end

  def on_message(m)
    begin
      return if m.type == :ping
      if m.type == :close
        on_close(m)
        return
      end

      message_received(m.data, m.type == :text)
    rescue Exception => e
      puts "Error processing SignalFlow message: #{e.backtrace.first}: #{e.message} (#{e.class})"
    end
  end

  def on_open
    @ws.send({
      :type => "authenticate",
      :token => @api_token,
    }.to_json)
  end

  # Start up a new WS client in its own thread that runs an EventMachine
  # reactor.
  def startup_client
    this = self
    WebSocket::Client::Simple.connect("#{@stream_endpoint}/v2/signalflow/connect") do |ws|
      @ws = ws
      ws.on :error do |e|
        puts "ERROR #{e.inspect}"
      end

      ws.on :close do |e|
        this.on_close(e)
      end

      ws.on :message do |m|
        this.on_message(m)
      end

      ws.on :open do
        this.on_open
      end
    end
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
      BinaryMessageParser.parse(raw_msg)
    end
  end
  private :parse_message

  def add_parsed_timestamp!(msg)
    if msg.has_key?(:timestampMs)
      msg[:timestamp] = Time.at(msg[:timestampMs]/1000)
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

