# Copyright (C) 2015-2016 SignalFx, Inc. All rights reserved.

require_relative 'signalfx/conf'
require_relative 'signalfx/protobuf_signal_fx_client'
require_relative 'signalfx/json_signal_fx_client'

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
  # @param stream_endpoint - string
  # @param timeout - number
  # @param batch_size - number
  # @param user_agents - array
  def self.new(api_token,
               enable_aws_unique_id: false,
               ingest_endpoint: RbConfig::DEFAULT_INGEST_ENDPOINT,
               stream_endpoint: RbConfig::DEFAULT_STREAM_ENDPOINT,
               timeout: RbConfig::DEFAULT_TIMEOUT,
               batch_size: RbConfig::DEFAULT_BATCH_SIZE,
               user_agents: [],
               ssl_ca_file: nil,
               ssl_client_cert: nil,
               ssl_client_key: nil,
               logger: Logger.new(STDOUT, progname: "signalfx"))
    begin
      require_relative './proto/signal_fx_protocol_buffers.pb'
      ProtoBufSignalFx.new(api_token,
                           enable_aws_unique_id: enable_aws_unique_id,
                           ingest_endpoint: ingest_endpoint,
                           stream_endpoint: stream_endpoint,
                           timeout: timeout,
                           batch_size: batch_size,
                           ssl_ca_file: ssl_ca_file,
                           ssl_client_cert: ssl_client_cert,
                           ssl_client_key: ssl_client_key,
                           user_agents: user_agents)

    rescue Exception => e
      logger.warn("Protocol Buffers not installed properly. Switching to JSON.
            #{e}")
      JsonSignalFx.new(api_token,
                       enable_aws_unique_id: enable_aws_unique_id,
                       ingest_endpoint: ingest_endpoint,
                       stream_endpoint: stream_endpoint,
                       timeout: timeout,
                       batch_size: batch_size,
                       ssl_ca_file: ssl_ca_file,
                       ssl_client_cert: ssl_client_cert,
                       ssl_client_key: ssl_client_key,
                       user_agents: user_agents)
    end
  end
end
