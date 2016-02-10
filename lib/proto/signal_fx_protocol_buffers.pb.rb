# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf'

module Com
  module Signalfx
    module Metrics
      module Protobuf

        ##
        # Enum Classes
        #
        class MetricType < ::Protobuf::Enum
          define :GAUGE, 0
          define :COUNTER, 1
          define :ENUM, 2
          define :CUMULATIVE_COUNTER, 3
        end

        class EventCategory < ::Protobuf::Enum
          define :USER_DEFINED, 1000000
          define :ALERT, 100000
          define :AUDIT, 200000
          define :JOB, 300000
          define :COLLECTD, 400000
          define :SERVICE_DISCOVERY, 500000
          define :EXCEPTION, 700000
        end


        ##
        # Message Classes
        #
        class Datum < ::Protobuf::Message; end
        class Dimension < ::Protobuf::Message; end
        class DataPoint < ::Protobuf::Message; end
        class DataPointUploadMessage < ::Protobuf::Message; end
        class PointValue < ::Protobuf::Message; end
        class Property < ::Protobuf::Message; end
        class PropertyValue < ::Protobuf::Message; end
        class Event < ::Protobuf::Message; end
        class EventUploadMessage < ::Protobuf::Message; end


        ##
        # Message Fields
        #
        class Datum
          optional :string, :strValue, 1
          optional :double, :doubleValue, 2
          optional :int64, :intValue, 3
        end

        class Dimension
          optional :string, :key, 1
          optional :string, :value, 2
        end

        class DataPoint
          optional :string, :source, 1
          optional :string, :metric, 2
          optional :int64, :timestamp, 3
          optional ::Com::Signalfx::Metrics::Protobuf::Datum, :value, 4
          optional ::Com::Signalfx::Metrics::Protobuf::MetricType, :metricType, 5
          repeated ::Com::Signalfx::Metrics::Protobuf::Dimension, :dimensions, 6
        end

        class DataPointUploadMessage
          repeated ::Com::Signalfx::Metrics::Protobuf::DataPoint, :datapoints, 1
        end

        class PointValue
          optional :int64, :timestamp, 3
          optional ::Com::Signalfx::Metrics::Protobuf::Datum, :value, 4
        end

        class Property
          optional :string, :key, 1
          optional ::Com::Signalfx::Metrics::Protobuf::PropertyValue, :value, 2
        end

        class PropertyValue
          optional :string, :strValue, 1
          optional :double, :doubleValue, 2
          optional :int64, :intValue, 3
          optional :bool, :boolValue, 4
        end

        class Event
          required :string, :eventType, 1
          repeated ::Com::Signalfx::Metrics::Protobuf::Dimension, :dimensions, 2
          repeated ::Com::Signalfx::Metrics::Protobuf::Property, :properties, 3
          optional ::Com::Signalfx::Metrics::Protobuf::EventCategory, :category, 4
          optional :int64, :timestamp, 5
        end

        class EventUploadMessage
          repeated ::Com::Signalfx::Metrics::Protobuf::Event, :events, 1
        end

      end

    end

  end

end

