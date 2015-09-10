# Copyright (C) 2015 SignalFx, Inc. All rights reserved.

require 'thread'
require "signalfx/conf"
require "signalfx/signal_fx_client"
require "proto/signal_fx_protocol_buffers.pb"

class ProtoBufSignalFx < SignalFxClient

  protected

  def header_content_type
    Config::PROTOBUF_HEADER_CONTENT_TYPE
  end


  def add_to_queue(metric_type, datapoint)
    protobuf_datapoint = Com::Signalfx::Metrics::Protobuf::DataPoint.new

    # assign value type
    datapoint_value = datapoint[:value]
    if datapoint_value.kind_of?(String)
      protobuf_datapoint.value = Com::Signalfx::Metrics::Protobuf::Datum.new :strValue => datapoint_value
    else
      if datapoint_value.kind_of?(Float)
        protobuf_datapoint.value = Com::Signalfx::Metrics::Protobuf::Datum.new :doubleValue => datapoint_value
      else
        if datapoint_value.kind_of?(Fixnum)
          protobuf_datapoint.value = Com::Signalfx::Metrics::Protobuf::Datum.new :intValue => datapoint_value
        else
          throw TypeError('Invalid Value ' + datapoint_value);
        end
      end
    end


    protobuf_datapoint.metricType = Com::Signalfx::Metrics::Protobuf::MetricType.const_get(metric_type.upcase)
    protobuf_datapoint.metric = datapoint[:metric]
    if datapoint[:timestamp] != nil
      protobuf_datapoint.timestamp = datapoint[:timestamp]
    end

    #set datapoint dimensions
    dimensions = Array.new
    if datapoint[:dimensions] != nil
      datapoint[:dimensions].each {
          |dimension| dimensions.push(
            Com::Signalfx::Metrics::Protobuf::Dimension.new :key => dimension[:key], :value => dimension[:value])
      }
    end
    protobuf_datapoint.dimensions = dimensions

    # add object to queue
    @queue.push(protobuf_datapoint)
  end


  def batch_data(data_point_list)
    dpum = Com::Signalfx::Metrics::Protobuf::DataPointUploadMessage.new
    data_point_list.each { |datapoint| dpum.datapoints << datapoint }
    dpum.to_s
  end
end