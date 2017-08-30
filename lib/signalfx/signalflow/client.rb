# Copyright (C) 2017 SignalFx, Inc. All rights reserved.

require 'thread'

require_relative "./websocket"

# A SignalFlow client that uses the WebSockets interface.
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
  # @option options [Fixnum] :start
  # @option options [Fixnum] :stop
  # @option options [Fixnum] :resolution
  # @option options [Fixnum] :max_delay
  # @option options [Boolean] :persistent
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
  # @param start [Fixnum]
  # @param stop [Fixnum]
  # @option options [Fixnum] :max_delay
  #
  # @return [Computation] A {Computation} instance with an active channel
  def preflight(program, start, stop, **options)
    @transport.preflight(program, start, stop, **options)
  end

  # Start a computation without attaching to it
  #
  # This is currently not very useful because you cannot attach to the
  # computation to see any output.  It also will not return the handle id.
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
