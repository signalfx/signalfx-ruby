# Copyright (C) 2017 SignalFx, Inc. All rights reserved.

require_relative './queue'

class ChannelTimeout < Exception
end

# Channel represents a medium through which SignalFlow messages pass.
# The main method for it is {#each_message}, which is how you get messages from
# the channel.  There can only be one user of a channel and they are NOT
# thread-safe.
#
# Channels are for one-time use only.  Once a channel is detached from (either
# manually or due to the end of a computation) previous messages will be
# iterable but nothing new will show up.
class Channel
  attr_accessor :name
  attr_accessor :detached

  def initialize(name, detach_cb)
    @lock = Mutex.new
    @detach_lock = Mutex.new
    @detached = false
    @name = name
    @detach_from_transport = detach_cb
    @messages = QueueWithTimeout.new
  end

  # Waits for and returns the next message in the channel.
  #
  # @param timeout_seconds [Float] Number of seconds to wait for a message.
  #
  # @return [Hash] The next message received by this channel.  A return value
  # of `nil` indicates that the channel has detected it is done and will not be
  # receiving any more useful messages.
  #
  # @raise [ChannelTimeout] If the timeout is exceeded with no messages
  def pop(timeout_seconds=nil)
    raise "Channel #{@name} is detached" if @detached

    msg = nil
    begin
      msg = @messages.pop_with_timeout(timeout_seconds)
    rescue ThreadError
      raise ChannelTimeout.new(
        "Did not receive a message on channel #{@name} within #{timeout_seconds} seconds")
    end

    if msg[:event] == "END_OF_CHANNEL" || msg[:event] == "CONNECTION_CLOSED" || msg[:event] == "CHANNEL_ABORT"
      # Mark this channel as detached and then return nil as an indicator that
      # this channel is done
      detach(false)

      nil
    else
      msg
    end

  end


  def detach(send_detach_to_server=true)
    if !@detached
      @detached = true
      @detach_from_transport.call if send_detach_to_server
      @detach_from_transport = nil
    end
  end

  def inject_message(msg)
    raise 'Not expecting to receive message on detached channel' if @detached
    raise 'Cannot inject nil message' if msg.nil?

    @messages << msg
  end

end
