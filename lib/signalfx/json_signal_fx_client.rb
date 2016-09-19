# Copyright (C) 2015-2016 SignalFx, Inc. All rights reserved.

require_relative './signal_fx_client'
require_relative './conf'
require 'json'

class JsonSignalFx < SignalFxClient

  protected

  def header_content_type
    RbConfig::JSON_HEADER_CONTENT_TYPE
  end

  def add_to_queue(metric_type, datapoint)
    #set datapoint dimensions
    dimensions = {}
    if datapoint[:dimensions] != nil
      datapoint[:dimensions].each {
          |dimension| dimensions[dimension[:key]] = dimension[:value]
      }
    end
    datapoint[:dimensions] = dimensions
    get_queue << {metric_type => datapoint}
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

  def build_event(event)
    event_list = []
    event_list << event
    event_list.to_json
  end
end
