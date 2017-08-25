# Represents a SignalFlow computation.  A computation can have a channel
# associated with it, but not necessarily (it could have been detached while
# the computation is still running).  New instances should only be created by
# the client.
class Computation
  attr_accessor :handle
  attr_accessor :channel

  def initialize(handle, attach_func, stop_func)
    @handle = handle
    @channel = nil
    @attach_func = attach_func
    @stop_func = stop_func
  end

  def channel=(channel)
    @channel = channel

    # This is done in a thread because of the circular nature of channels and
    # computations in order to avoid trying to grab the same lock recursively
    # in the channel.  The channel is set in response to a message on the
    # channel and we can't iterate messages while processing a message.
    Thread.new do
      channel.each_message_async do |msg, detach|
        extract_metadata_from_message(msg)
      end
    end
  end

  def attached?
    @channel && !@channel.detached
  end

  # Iterates over the messages asynchronously for this computation.  See
  # {Channel#each_message_async}.
  def each_message_async(&block)
    raise 'This computation does not have a channel' unless @channel

    @channel.each_message_async(&block)
    return
  end

  # Iterates over the messages for this computation.  See
  # {Channel#each_message}.
  def each_message(&block)
    raise 'This computation does not have a channel' unless @channel

    @channel.each_message(&block)
    return
  end

  # Attach to an already running computation.
  #
  # *Not currently implemented on backend!*
  #
  # @return [Computation] This computation instance with a now active channel
  # attached to it.
  def attach(**options)
    @channel = @attach_func.call(@handle, **options)
    self
  end

  # Stop a computation
  #
  # See https://developers.signalfx.com/v2/reference#section-stop-a-computation
  #
  # @param reason [String] Reason for stopping the computation.
  def stop(reason=nil)
    @stop_func.call(@handle, reason)
  end

  def extract_metadata_from_message(msg)
  end
end
