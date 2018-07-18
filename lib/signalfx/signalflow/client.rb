# Copyright (C) 2017 SignalFx, Inc. All rights reserved.

require 'thread'

require_relative "./websocket"

# A SignalFlow client that uses the WebSockets interface.
#
# See https://developers.signalfx.com/v2/reference#signalflowconnect for
# low-level API details and information on the SignalFlow language.
#
# See
# {https://github.com/signalfx/signalfx-ruby/blob/master/examples/signalflow.rb}
# for an example script that uses the client.
#
# The messages passed into the `computation.each_message*` blocks will be
# decoded forms of what is described in
# {https://developers.signalfx.com/v2/reference#information-messages-specification
# our API reference for SignalFlow}.  Hash keys will be symbols instead of
# strings.
class SignalFlowClient
  def initialize(api_token, api_endpoint, stream_endpoint)
    @transport = SignalFlowWebsocketTransport.new(api_token, stream_endpoint)
  end

  # Start a computation and attach to its output. If using WebSockets (the
  # default), the channel name is handled internally so you do not need to
  # supply it.
  #
  # See https://developers.signalfx.com/reference#section-execute-a-computation
  #
  # @option options [Integer] :start
  # @option options [Integer] :stop
  # @option options [Integer] :resolution
  # @option options [Integer] :max_delay
  # @option options [Boolean] :persistent
  # @option options [Boolean] :immediate
  #
  # @return [Computation] A {Computation} instance with an active channel
  def execute(program, **options)
    @transport.execute(program, **options)
  end

  # Start and attach to a computation that tells how many times a detector
  # would have fired in a time range between `start` and `stop`.
  #
  # See https://developers.signalfx.com/v2/reference#signalflowpreflight
  #
  # @param start [Integer]
  # @param stop [Integer]
  # @option options [Integer] :max_delay
  #
  # @return [Computation] A {Computation} instance with an active channel
  def preflight(program, start, stop, **options)
    @transport.preflight(program, start, stop, **options)
  end

  # Start a computation without attaching to it
  #
  # The `publish()` call in the program must specify a `metric` to publish the
  # output to since you cannot currently attach to the output.
  #
  # Optional parameters are the same as {#execute}.
  # @return [Computation] A {Computation} instance with a handle but without a
  #   channel
  def start(program, **options)
    @transport.start(program, **options)
  end

  # Stop everything and close any open connections.
  def close
    @transport.close
  end
end
