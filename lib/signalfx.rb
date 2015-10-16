# Copyright (C) 2015 SignalFx, Inc. All rights reserved.

require 'signalfx/conf'
require 'signalfx/protobuf_signal_fx_client'
require 'signalfx/json_signal_fx_client'

module SignalFx

  # SignalFx API client.
  # This class presents a programmatic interface to SignalFx's metadata and
  # ingest APIs. At the time being, only ingest is supported; more will come
  # later.
  #
  # @param api_token - Your private SignalFx token
  # @param enable_aws_unique_id - boolean, `false` by default.
  #     If `true`, library will retrieve Amazon unique identifier
  #     and set it as `AWSUniqueId` dimension for each datapoint and event.
  #     Use this option only if your application deployed to Amazon
  # @param ingest_endpoint - string
  # @param api_endpoint - string
  # @param timeout - number
  # @param batch_size - number
  # @param user_agents - array
  def self.new(api_token, enable_aws_unique_id: false, ingest_endpoint: Config::DEFAULT_INGEST_ENDPOINT,
      api_endpoint: Config::DEFAULT_API_ENDPOINT, timeout: Config::DEFAULT_TIMEOUT,
      batch_size: Config::DEFAULT_BATCH_SIZE, user_agents: [])
    begin
      require 'proto/signal_fx_protocol_buffers.pb'
      ProtoBufSignalFx.new(api_token, enable_aws_unique_id: enable_aws_unique_id, ingest_endpoint: ingest_endpoint,
                           api_endpoint: api_endpoint, timeout: timeout,
                           batch_size: batch_size, user_agents: user_agents)

    rescue Exception => e
      puts "Protocol Buffers not installed properly. Switch to JSON.
            #{e}"
      JsonSignalFx.new(api_token, enable_aws_unique_id: enable_aws_unique_id, ingest_endpoint: ingest_endpoint,
                       api_endpoint: api_endpoint, timeout: timeout,
                       batch_size: batch_size, user_agents: user_agents)
    end


  end
end