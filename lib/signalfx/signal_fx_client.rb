# Copyright (C) 2015 SignalFx, Inc. All rights reserved.

require 'signalfx/version'
require 'signalfx/conf'

require 'net/http'
require 'uri'
require 'openssl'

class SignalFxClient
  HEADER_API_TOKEN_KEY = 'X-SF-Token'
  HEADER_USER_AGENT_KEY = 'User-Agent'
  HEADER_CONTENT_TYPE = 'Content-Type'
  INGEST_ENDPOINT_SUFFIX = 'v2/datapoint'
  API_ENDPOINT_SUFFIX = 'v1/event'

  def initialize(api_token, ingest_endpoint: Config::DEFAULT_INGEST_ENDPOINT,
                 api_endpoint: Config::DEFAULT_API_ENDPOINT, timeout: Config::DEFAULT_TIMEOUT,
                 batch_size: Config::DEFAULT_BATCH_SIZE, user_agents: [])

    @api_token = api_token
    @ingest_endpoint = ingest_endpoint
    @api_endpoint = api_endpoint
    @timeout = timeout
    @batch_size = batch_size
    @user_agents = user_agents

    @queue = Queue.new
    @async_running = false
  end

  #Send the given metrics to SignalFx synchronously.
  #You can use this method to send data via reporters such as Codahale style libraries
  #
  #Args:
  #    cumulative_counters (list): a list of dictionaries representing the
  #                 cumulative counters to report.
  #    gauges (list): a list of dictionaries representing the gauges to report.
  #    counters (list): a list of dictionaries representing the counters to report.
  def send(cumulative_counters: nil, gauges: nil, counters: nil)
    process_datapoint('cumulative_counter', cumulative_counters)
    process_datapoint('gauge', gauges)
    process_datapoint('counter', counters)

    data_points_list = []
    while @queue.length > 0 && data_points_list.length < @batch_size
      data_points_list << @queue.pop
    end

    data_to_send = batch_data(data_points_list)

    begin
      post(data_to_send, @ingest_endpoint, INGEST_ENDPOINT_SUFFIX)
    ensure
      @async_running = false
    end
  end

  #Send the given metrics to SignalFx asynchronously.
  #
  #Args:
  #    cumulative_counters (list): a list of dictionaries representing the
  #                 cumulative counters to report.
  #    gauges (list): a list of dictionaries representing the gauges to report.
  #    counters (list): a list of dictionaries representing the counters to report.
  def send_async(cumulative_counters: nil, gauges: nil, counters: nil)
    process_datapoint('cumulative_counter', cumulative_counters)
    process_datapoint('gauge', gauges)
    process_datapoint('counter', counters)

    if @async_running
      return
    end

    data_points_list = []
    while @queue.length > 0 && data_points_list.length < @batch_size
      data_points_list << @queue.pop
    end

    data_to_send = batch_data(data_points_list)

    @async_running = true

    Thread.abort_on_exception = true
    Thread.start {
      begin
        post(data_to_send, @ingest_endpoint, INGEST_ENDPOINT_SUFFIX)
      ensure
        @async_running = false
      end
    }
  end


  #Send an event to SignalFx.
  #
  #Args:
  #    event_type (string): the event type (name of the event time series).
  #    dimensions (dict): a map of event dimensions.
  #    properties (dict): a map of extra properties on that event.
  def send_event(event_type, dimensions: {}, properties: {})

    #TODO: Add AWS Unique ID to dimensions array
    #TODO: Add pre-defined dimensions to dimensions array
    data = {
        eventType: event_type,
        dimensions: dimensions,
        properties: properties
    }

    post(data.to_json, @api_endpoint, API_ENDPOINT_SUFFIX, Config::JSON_HEADER_CONTENT_TYPE)
  end

  protected

  def header_content_type
    raise 'Subclasses should implement this!'
  end

  def add_to_queue(metric_type, datapoint)
    raise 'Subclasses should implement this!'
  end

  def batch_data(data_point_list)
    raise 'Subclasses should implement this!'
  end

  private

  def post(data_to_send, url, suffix, content_type = nil)
    uri = URI.parse(url + '/' + suffix)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.read_timeout = @timeout

    http_user_agents = ''
    if @user_agents != nil && @user_agents.length > 0
      http_user_agents = ', ' + @user_agents.join(', ')
    end

    headers = {HEADER_CONTENT_TYPE => content_type != nil ? content_type : header_content_type,
               HEADER_API_TOKEN_KEY => @api_token,
               HEADER_USER_AGENT_KEY => Version::NAME + '/' + Version::VERSION + http_user_agents}
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = data_to_send

    begin
      response = http.request(request)
      if response.code != "200"
        puts "Failed to sent datapoint. Response code: #{response.code}"
      end
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      puts "Failed to sent datapoint. Error: #{e}"
    rescue Exception => e
      puts "BAD STUFF #{e} #{data_to_send}"
    end

  end

  def process_datapoint(metric_type, data_points)
    if data_points != nil && data_points.kind_of?(Array)
      #TODO: Add AWS Unique ID to each datapoint
      #TODO: Add pre-defined dimensions to each datapoint
      data_points.each { |datapoint| add_to_queue(metric_type, datapoint) }
    end
  end
end