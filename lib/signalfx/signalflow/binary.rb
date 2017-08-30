# Copyright (C) 2017 SignalFx, Inc. All rights reserved.

require 'json'
require 'zlib'

# Converts binary websocket messages into a hash
module BinaryMessageParser
  # data should be a raw string
  def parse(data)
    # See https://developers.signalfx.com/v2/reference#section-binary-encoding-of-websocket-messages
    version, message_type, flags, _, channel, payload = data.unpack("CCb8CZ16a*")
    compressed = flags[0] == "1"
    is_json = flags[1] == "1"

    if version != 1
      raise "Unsupported SignalFlow version #{version}"
    end

    if compressed
      payload = Zlib::Inflate.new(16+Zlib::MAX_WBITS).inflate(payload)
    end

    raise "Unknown binary message type #{message_type}" if !is_json && message_type != 5

    message = is_json ?
                JSON.parse(payload, {:symbolize_names => true}) :
                parse_data_payload(payload)

    message.merge({:channel => channel})
  end
  module_function :parse

  def parse_data_payload(payload)
    # See https://developers.signalfx.com/v2/reference#section-binary-encoding-used-for-the-websocket
    timestamp, element_count, tuples_raw = payload.unpack("Q>L>a*")
    data_hash = (0..element_count-1).map do |i|
      type, tsid, value_raw = tuples_raw[i*17..i*17+16].unpack("CQ>a8")

      value = case type
              when 1  # long
                value_raw.unpack("q>")
              when 2  # double
                value_raw.unpack("G")
              when 3  # int (32 bit)
                value_raw.unpack("l>")
              end

      [
        tsid,
        value[0],
      ]
    end.to_h

    {
      :type => "data",
      :logicalTimestampMs => timestamp,
      :logicalTimestamp => Time.at(timestamp / 1000.0),
      :data => data_hash,
    }
  end
  module_function :parse_data_payload
end
