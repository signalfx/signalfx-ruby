# Copyright (C) 2015-2016 SignalFx, Inc. All rights reserved.

require_relative './version'
require_relative './conf'
require_relative './signalflow/client'

require 'net/http'
require 'uri'
require 'openssl'
require 'rest-client'

class SignalFxClient
  HEADER_API_TOKEN_KEY = 'X-SF-Token'
  HEADER_USER_AGENT_KEY = 'User-Agent'
  HEADER_CONTENT_TYPE = 'Content-Type'
  INGEST_ENDPOINT_SUFFIX = 'v2/datapoint'
  EVENT_ENDPOINT_SUFFIX = 'v2/event'

  EVENT_CATEGORIES = {
      USER_DEFINED: 'USER_DEFINED',
      ALERT: 'ALERT',
      AUDIT: 'AUDIT',
      JOB: 'JOB',
      COLLECTD: 'COLLECTD',
      SERVICE_DISCOVERY: 'SERVICE_DISCOVERY',
      EXCEPTION: 'EXCEPTION'
  }

  $event_categories = EVENT_CATEGORIES

  def initialize(api_token,
                 enable_aws_unique_id: false,
                 ingest_endpoint: RbConfig::DEFAULT_INGEST_ENDPOINT,
                 api_endpoint: RbConfig::DEFAULT_API_ENDPOINT,
                 stream_endpoint: RbConfig::DEFAULT_STREAM_ENDPOINT,
                 timeout: RbConfig::DEFAULT_TIMEOUT,
                 batch_size: RbConfig::DEFAULT_BATCH_SIZE,
                 user_agents: [])

    @api_token = api_token
    @ingest_endpoint = ingest_endpoint
    @api_endpoint = api_endpoint
    @stream_endpoint = stream_endpoint
    @timeout = timeout
    @batch_size = batch_size
    @user_agents = user_agents

    @aws_unique_id = nil

    @queue = Queue.new
    @async_running = false

    if enable_aws_unique_id
      retrieve_aws_unique_id { |request|
        if request != nil
          json_resp = JSON.parse(request.body)
          @aws_unique_id = json_resp['instanceId']+'_'+json_resp['region']+'_'+json_resp['accountId']
          puts("AWS Unique ID loaded: #{@aws_unique_id}")
        else
          puts('Failed to retrieve AWS unique ID.')
        end
      }
    end
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
      data_points_list << @queue.shift
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
      data_points_list << @queue.shift
    end

    data_to_send = batch_data(data_points_list)

    @async_running = true

    Thread.abort_on_exception = true
    Thread.start {
      begin
        post(data_to_send, @ingest_endpoint, INGEST_ENDPOINT_SUFFIX) {
          @async_running = false
        }
      ensure
        @async_running = false
      end
    }
  end


  #Send an event to SignalFx.
  #
  #Args:
  #    event_type (string): the event type (name of the event time series).
  #    event_category (string): the category of event. Choose one from EVENT_CATEGORIES list
  #    dimensions (dict): a map of event dimensions.
  #    properties (dict): a map of extra properties on that event.
  #    timestamp (int64): a timestamp, by default is current time
  def send_event(event_type, event_category: EVENT_CATEGORIES[:USER_DEFINED],
                 dimensions: {}, properties: {}, timestamp: (Time.now.to_i * 1000).to_i)
    if event_type.blank?
      raise 'Type of event should not be empty!'
    end

    event_cat = event_category
    if event_category.blank?
      event_cat = EVENT_CATEGORIES[:USER_DEFINED]
    end

    if !event_cat.blank? and !EVENT_CATEGORIES.has_value?(event_cat)
      raise 'Unsupported event category: ' + event_cat
    end

    data = {
        category: event_cat,
        eventType: event_type,
        dimensions: dimensions,
        properties: properties,
        timestamp: timestamp
    }

    if @aws_unique_id
      data[:dimensions][RbConfig::AWS_UNIQUE_ID_DIMENSION_NAME] = @aws_unique_id
    end

    post(build_event(data), @ingest_endpoint, EVENT_ENDPOINT_SUFFIX)
  end

  # Create a new SignalFlow client.  A single client can execute multiple
  # computations that will be multiplexed over the same WebSocket connection.
  #
  # @return [SignalFlowClient] a newly instantiated client, configured with the
  #   api token and endpoints from this class
  def signalflow
    SignalFlowClient.new(@api_token, @api_endpoint, @stream_endpoint)
  end

  protected

  def get_queue
    @queue
  end

  def header_content_type
    raise 'Subclasses should implement this!'
  end

  def add_to_queue(metric_type, datapoint)
    raise 'Subclasses should implement this!'
  end

  def batch_data(data_point_list)
    raise 'Subclasses should implement this!'
  end

  def build_event(event)
    raise 'Subclasses should implement this!'
  end

  private

  def post(data_to_send, url, suffix, &block)
    begin
      http_user_agents = ''
      if @user_agents != nil && @user_agents.length > 0
        http_user_agents = ', ' + @user_agents.join(', ')
      end

      headers = {HEADER_CONTENT_TYPE => header_content_type,
                 HEADER_API_TOKEN_KEY => @api_token,
                 HEADER_USER_AGENT_KEY => Version::NAME + '/' + Version::VERSION + http_user_agents}

      RestClient::Request.execute(
          method: :post,
          url: url + '/' + suffix,
          headers: headers,
          payload: data_to_send,
          verify_ssl: OpenSSL::SSL::VERIFY_PEER,
          timeout: @timeout) { |response|
        case response.code
          when 200
            if block
              block.call(response)
            end
          else
            puts "Failed to send datapoints. Response code: #{response.code}"
            if block
              block.call(nil)
            end
        end
      }
    rescue Exception => e
      puts "Failed to send datapoints. Error: #{e}"
      if block
        block.call(nil)
      end
    end
  end

  def retrieve_aws_unique_id(&block)
    begin
      RestClient::Request.execute(method: :get,
                                  url: RbConfig::AWS_UNIQUE_ID_URL,
                                  timeout: 1) { |response|
        case response.code
          when 200
            return block.call(response)
          else
            puts "Failed to retrieve AWS unique ID. Response code: #{response.code}"
            return block.call(nil)
        end
      }
    rescue Exception => e
      puts "Failed to retrieve AWS unique ID. Error: #{e}"
      block.call(nil)
    end
  end

  def process_datapoint(metric_type, data_points)
    if data_points != nil && data_points.kind_of?(Array)
      data_points.each { |datapoint|
        if @aws_unique_id
          if datapoint[:dimensions] == nil
            datapoint[:dimensions] = []
          end
          datapoint[:dimensions] << {:key => RbConfig::AWS_UNIQUE_ID_DIMENSION_NAME, :value => @aws_unique_id}
        end

        add_to_queue(metric_type, datapoint)
      }
    end
  end
end
