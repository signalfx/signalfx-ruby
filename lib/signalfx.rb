# Copyright (C) 2015 SignalFx, Inc. All rights reserved.

require 'signalfx/conf'
require 'signalfx/protobuf_signal_fx_client'
require 'signalfx/json_signal_fx_client'

module SignalFx
  def self.new(api_token, ingest_endpoint: Config::DEFAULT_INGEST_ENDPOINT,
      api_endpoint: Config::DEFAULT_API_ENDPOINT, timeout: Config::DEFAULT_TIMEOUT,
      batch_size: Config::DEFAULT_BATCH_SIZE, user_agents: [])
    begin
      require 'proto/signal_fx_protocol_buffers.pb'
      ProtoBufSignalFx.new(api_token, ingest_endpoint: ingest_endpoint,
                           api_endpoint: api_endpoint, timeout: timeout,
                           batch_size: batch_size, user_agents: user_agents)

    rescue Exception => e
      puts "Protocol Buffers not installed properly. Switch to JSON.
            #{e}"
      JsonSignalFx.new(api_token, ingest_endpoint: ingest_endpoint,
                       api_endpoint: api_endpoint, timeout: timeout,
                       batch_size: batch_size, user_agents: user_agents)
    end


  end
end