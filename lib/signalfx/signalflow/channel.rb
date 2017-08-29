# Channel represents a medium through which SignalFlow messages pass.
# The main method for it is {#each_message}, which is how you get messages from
# the channel.
#
# Channels are for one-time use only.  Once a channel is detached from (either
# manually or due to the end of a computation) previous messages will be
# iterable but nothing new will show up.
class Channel
  attr_accessor :name
  attr_accessor :computation
  attr_accessor :detached

  def initialize(name, detach_cb)
    @lock = Mutex.new
    @detach_lock = Mutex.new
    @cb_lock = Mutex.new
    @detached = false
    @name = name
    @detach_from_transport = detach_cb
    @cbs = []
    # Cache every message that comes in on this channel so that we can replay
    # them when iterating messages and avoid races.
    @messages = []
  end

  def computation=(comp)
    @computation = comp
  end

  # Call a block with each message asynchronously.  Returns immediately.
  #
  # @yield [msg, detach] Called when a message arrives that is relevant to the
  #   channel's computation.  The `detach` param will be set to a function that can
  #   be called by the block to detach from the computation.
  def each_message_async(&block)
    raise 'each_message_async() requires block' unless block

    @cb_lock.synchronize do
      replay_existing_messages(&block)
      return if @detached

      @cbs << block
    end
    return
  end

  # Call the given block with each message in the channel as they arrive.  This
  # method will not return until the channel is detached from (either manually
  # or due to the computation ending).
  #
  # @yield [msg, detach] Called when a message arrives that is relevant to the
  #   channel's computation.  The `detach` param will be set to a function that can
  #   be called by the block to detach from the computation.
  def each_message(&block)
    raise 'each_message() requires block' unless block

    wait_lock = Mutex.new
    cv = ConditionVariable.new

    @cb_lock.synchronize do
      replay_existing_messages(&block)

      return if @detached

      @cbs << ->(msg, detach) do
        send_message_to_block(msg, &block)
        if @detached
          wait_lock.synchronize do
            cv.signal
          end
        end
      end
    end

    wait_lock.synchronize do
      begin
        if !@detached
          cv.wait(wait_lock)
        end
      rescue Exception
        detach(false)
      end
    end
    return
  end

  def detach(send_detach_to_server=true)
    if !@detached
      # Send a special sentinal message so that waiting iterators know to
      # stop
      @detached = true
      @cbs.each {|cb| cb.call({:channel => @name, :event => "CHANNEL_DETACHED"}, nil)}
      @computation = nil
      @detach_from_transport.call if send_detach_to_server
      @detach_from_transport = nil
      @cbs = []
    end
  end

  def inject_message(msg)
    @lock.synchronize do
      @cb_lock.synchronize do
        return if @detached
        @messages << msg
        @cbs.each {|cb| send_message_to_block(msg, &cb)}
        if msg[:event] == "END_OF_CHANNEL" || msg[:event] == "CONNECTION_CLOSED" || msg[:event] == "CHANNEL_ABORT"
          detach(false)
        end
      end
    end
  end

  # Returns false if detach was called within the block
  def send_message_to_block(msg, &block)
    detach_called = false

    block.call(msg, ->() do
      detach
      detach_called = true
    end)

    !detach_called
  end
  private :send_message_to_block

  def replay_existing_messages(&block)
    @lock.synchronize do
      # Replay all previously gotten messages (stopping if detach was called)
      @messages.each do |m| 
        if !send_message_to_block(m, &block)
          return
        end
      end
    end
  end
  private :replay_existing_messages
end
