# Copyright (C) 2017 SignalFx, Inc. All rights reserved.

require 'json'
require 'zlib'

# Converts binary websocket messages into a hash
module BinaryMessageParser
  # data should be a raw string
  def parse(data)
    # See https://developers.signalfx.com/v2/reference#section-binary-encoding-of-websocket-messages
    # Second var is message type but we don't care about it since it is a
    # rather opaque integer that can be many things when compression is on.
    version, _, flags, _, channel, payload = data.unpack("CCb8CZ16a*")
    compressed = flags[0] == "1"
    is_json = flags[1] == "1"

    if version != 1
      raise "Unsupported SignalFlow version #{version}"
    end

    if compressed
      payload = Zlib::Inflate.new(16+Zlib::MAX_WBITS).inflate(payload)
    end

    message = is_json ?
                JSON.parse(payload, {:symbolize_names => true}) :
                parse_binary_payload(payload)

    message.merge({:channel => channel})
  end
  module_function :parse

  def parse_binary_payload(payload)
    # See https://developers.signalfx.com/v2/reference#section-binary-encoding-used-for-the-websocket
    timestamp, element_count, tuples_raw = payload.unpack("Q>L>a*")
    tuple_hashes = (0..element_count-1).map do |i|
      type, tsid, value_raw = tuples_raw[i*17..i*17+16].unpack("CQ>a8")

      value = case type
              when 1  # long
                value_raw.unpack("q>")
              when 2  # double
                value_raw.unpack("G")
              when 3  # int (32 bit)
                value_raw.unpack("l>")
              end

      {
        :timeseries_id => tsid,
        :value => value[0],
      }
    end

    {
      :type => "data",
      :timestampMs => timestamp,
      :data => tuple_hashes,
    }
  end
  module_function :parse_binary_payload
end
