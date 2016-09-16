# Copyright (C) 2015-2016 SignalFx, Inc. All rights reserved.

require 'thread'
require_relative './conf'
require_relative './signal_fx_client'
require_relative '../proto/signal_fx_protocol_buffers.pb'

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
    get_queue. << protobuf_datapoint
  end


  def batch_data(data_point_list)
    dpum = Com::Signalfx::Metrics::Protobuf::DataPointUploadMessage.new
    data_point_list.each { |datapoint| dpum.datapoints << datapoint }
    dpum.to_s
  end

  def build_event(event)
    protobuf_event = Com::Signalfx::Metrics::Protobuf::Event.new
    if event[:eventType]
      protobuf_event.eventType = event[:eventType]
    end

    if event[:category]
      protobuf_event.category = Com::Signalfx::Metrics::Protobuf::EventCategory.const_get(event[:category].upcase)
    end

    if event[:timestamp]
      protobuf_event.timestamp = event[:timestamp];
    end

    #set datapoint dimensions
    dimensions = Array.new
    if event[:dimensions] != nil
      event[:dimensions].each {
          |key, value| dimensions.push(
            Com::Signalfx::Metrics::Protobuf::Dimension.new :key => key, :value => value)
      }
    end
    protobuf_event.dimensions = dimensions

    # assign value type
    protobuf_event.properties = []
    event[:properties].each { |prop_key, prop_value |
      property = Com::Signalfx::Metrics::Protobuf::Property.new
      property.key = prop_key
      if prop_value.kind_of?(String)
        property.value = Com::Signalfx::Metrics::Protobuf::PropertyValue.new :strValue => prop_value
      else
        if prop_value.kind_of?(Float)
          property.value = Com::Signalfx::Metrics::Protobuf::PropertyValue.new :doubleValue => prop_value
        else
          if prop_value.kind_of?(Fixnum)
            property.value = Com::Signalfx::Metrics::Protobuf::PropertyValue.new :intValue => prop_value
          else
            throw TypeError('Invalid Value ' + prop_value);
          end
        end
      end
      protobuf_event.properties << property
    }

    event_msg = Com::Signalfx::Metrics::Protobuf::EventUploadMessage.new
    event_msg[:events] = Array.new
    event_msg[:events] << protobuf_event
    event_msg.to_s
  end
end
