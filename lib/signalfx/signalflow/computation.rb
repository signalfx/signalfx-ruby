# Copyright (C) 2017 SignalFx, Inc. All rights reserved.


STARTED_STATE = :started
ABORTED_STATE = :aborted
COMPLETED_STATE = :completed
DATA_STREAMING_STATE = :data_streaming

# Represents a SignalFlow computation/job.  A computation can have a channel
# associated with it, but not necessarily (it could have been detached while
# the computation is still running or never attached in the first place).  New
# instances should only be created by the client and a Computation MUST have a
# handle.
class Computation
  attr_accessor :handle
  attr_accessor :channel
  attr_accessor :state
  attr_accessor :metadata

  def initialize(handle, attach_func, stop_func)
    @handle = handle
    @channel = nil
    @attach_func = attach_func
    @stop_func = stop_func
    @metadata = {}
    # We can't have a handle until the job is started so we must be at least
    # at this state
    @state = STARTED_STATE

    @pending_messages = Queue.new

    @batch_size_known = false
    @expected_batch_size = 0
    @current_batch_data = nil
    @current_batch_size = nil
  end

  def channel=(channel)
    @channel = channel
  end

  def attached?
    !@channel.nil? && !@channel.detached
  end

  # Get the next message in this computation.
  #
  # @param timeout_seconds [Float] If a new message does not come within this
  #   interval, raises a {ChannelTimeout} exception.  Note that this does not
  #   mean that this function will return within this interval since there may
  #   be messages received that are part of a larger batch.  If nil, will block
  #   indefinitely.
  def next_message(timeout_seconds=nil)
    raise "Computation #{@handle} is not attached to a channel" unless @channel

    # This intermediate message queue exists because data can come in batches.
    # Due to the logic to determine these batches, the arrival of a single
    # message on the channel might release multiple messages.  This is where
    # those multiple messages can live until they are pulled off by the user
    # calling `next_message`.
    while @pending_messages.length == 0
      # process_message might return no messages if it is building up a batch
      msgs = process_message(@channel.pop(timeout_seconds))
      msgs.each {|m| @pending_messages << m}
    end

    @pending_messages.pop
  end

  # Iterates over the messages asynchronously for this computation.  A convenience
  # function if you want to fire off multiple computations simultaneously,
  # though not terribly efficient since it starts a new thread that spends a
  # lot of time waiting.  However, since we don't have a way of "select"ing on
  # computations, this is probably good enough for basic use.
  #
  # See {#each_message}.
  def each_message_async(&block)
    raise "Computation #{@handle} is not attached to a channel" unless @channel

    Thread.new{ each_message(&block) }
    return
  end

  # Call the given block with each message in the channel as they arrive.  This
  # method will not return until the channel is detached from (either manually
  # or due to the computation ending).
  #
  # Messages are queued in the channel so that none will be lost.
  #
  # @yield [msg, computation] Called when a message arrives that is relevant to the
  #   channel's computation.  The `computation` param will be set to this
  #   instance for easy referencing of computation metadata and state.
  def each_message(&block)
    raise "Computation #{@handle} is not attached to a channel" unless @channel

    while @channel
      msg = next_message
      block.call(msg, self)
    end

    return
  end

  # Process the given message
  def process_message(msg)
    out_messages = []
    # nil is like EOF for channels
    if msg.nil?
      @channel = nil
      out_messages << reset_current_batch
      out_messages << nil
    else
      # Sniff messages and update computation
      case msg[:type]
      when "metadata"
        @metadata[msg[:tsId]] = msg[:properties]
        out_messages << msg

      when "expired-tsid"
        @metadata.delete(msg[:tsId])
        out_messages << msg

      when "control-message"
        case msg[:event]
        when "CHANNEL_ABORT"
          @state = ABORTED_STATE
        when "END_OF_CHANNEL"
          @state = COMPLETED_STATE
        end

        out_messages << msg

      when "message"
        # The server guarantees that an initial batch of data will be sent before
        # the first "message" message.  Therefore, when we see a message of this
        # type, we know we have determined the batch size.
        @batch_size_known = true
        out_messages << msg
        # We also know that the current batch is done
        (out_messages << reset_current_batch) if @current_batch_size > 0

      when "data"
        @state = DATA_STREAMING_STATE

        # The expected batch size is the number of data messages received before
        # either the first arrival of a "message" message or receiving two data
        # messages with different logical timestamps.
        if !@batch_size_known
          @expected_batch_size += 1
        end

        if @current_batch_data && msg.fetch(:logicalTimestampMs) != @current_batch_data.fetch(:logicalTimestampMs)
          # Two data messages back to back with different timestamps before
          # receiving the first "message" message indicate that the previous
          # batch is done and our batch size is now whatever the total data
          # messages seen up until this point.
          @batch_size_known = true
          out_messages << reset_current_batch
          add_to_current_batch(msg)
        else
          add_to_current_batch(msg)
          if @batch_size_known && @current_batch_size == @expected_batch_size
            out_messages << reset_current_batch
          end
        end

      when "error"
        raise ComputationFailure.new(msg[:errors])
      else
        out_messages << msg
      end
    end

    out_messages
  end
  private :process_message

  # Add to the current batch, initializing the current batch if not already
  # set.
  def add_to_current_batch(msg)
    if !@current_data_batch
      @current_data_batch = msg
      @current_batch_size = 1
    else
      @current_data_batch[:data].merge!(msg.fetch(:data))
      @current_batch_size += 1
    end
  end
  private :add_to_current_batch

  # Resets the current batch, returning the previous value
  def reset_current_batch
    msg = @current_data_batch
    @current_data_batch = nil
    @current_batch_size = 0
    msg
  end
  private :reset_current_batch

  # Attach to an already running computation.
  #
  # *Not currently implemented on backend!*
  #
  # @return [Computation] This same computation instance with a now active
  # channel attached to it.
  def attach(**options)
    raise "Computation #{@handle} is already attached!" if @channel

    @channel = @attach_func.call(@handle, **options)
    self
  end

  # Detach from this computation and remove reference to the channel to free up
  # memory.
  def detach
    @channel.detach
    @channel = nil
  end

  # Stop a computation
  #
  # See https://developers.signalfx.com/v2/reference#section-stop-a-computation
  #
  # @param reason [String] Reason for stopping the computation.
  def stop(reason=nil)
    @stop_func.call(@handle, reason)
  end
end

class ComputationFailure < Exception
end
