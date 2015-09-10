require 'simplecov'
SimpleCov.start

require 'rspec/mocks'

require 'webmock/rspec'
WebMock.disable_net_connect!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'signalfx'
require 'signalfx/json_signal_fx_client'
require 'signalfx/protobuf_signal_fx_client'