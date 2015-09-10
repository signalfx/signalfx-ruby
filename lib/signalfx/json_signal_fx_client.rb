# Copyright (C) 2015 SignalFx, Inc. All rights reserved.

require "signalfx/signal_fx_client"
require "signalfx/conf"
require "json"

class JsonSignalFx < SignalFxClient

  protected

  def header_content_type
    Config::JSON_HEADER_CONTENT_TYPE
  end

  def add_to_queue(metric_type, datapoint)
    @queue.push({metric_type => datapoint})
  end

  def batch_data(data_point_list)
    data = Hash.new
    data_point_list.each do |datapoint|
      datapoint.each do |key, value|
        if data[key] == nil
          data[key] = []
        end
        data[key] << value
      end
    end

    data.to_json
  end
end