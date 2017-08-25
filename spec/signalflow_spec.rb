require 'socket'
require 'timeout'
require 'spec_helper'

require_relative './fake_signalflow/server'

TOKEN = 'mytoken'

# Wait until the computation that is executed in the block gives `count`
# messages.  The computation done in the block must use async iteration of
# messages to make timeouts work.
def wait_for_messages(count=1, timeout=10, &block)
  lock = Mutex.new
  message_cv = ConditionVariable.new
  messages = []

  yield ->(msg, detach){
    lock.synchronize do
      messages << msg
      message_cv.signal if messages.length == count
    end
  }
  lock.synchronize do
    if messages.length < count
      message_cv.wait(lock, timeout)
    end
  end
  return messages
end

def wait_for_port_to_open(ip, port)
  begin
    Timeout::timeout(5) do
      while true
        begin
          s = TCPSocket.new(ip, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          sleep 0.1
        end
      end
    end
  rescue Timeout::Error
  end

  return false
end

def wait_for_notice(pipe, notice, timeout=3)
  Timeout::timeout(timeout) do
    while true
      out = pipe.gets
      next if out.nil?
      if out.start_with? notice
        return out.strip
      end
    end
  end
  fail "Did not receive notice #{notice} from server within #{timeout} seconds"
end

describe 'SignalFlow (Websocket)' do
  host = '127.0.5.55'
  port = 23456
  sf = nil
  server_pid = nil
  reader, writer = IO.pipe

  before(:all) do
    # Fork off the fake server so that it doesn't interfere with the EM that
    # runs the client.  The two do NOT coexist well at all.
    pid = Process.fork
    if !pid
      # child proc
      reader.close
      # Turn off any output so it doesn't pollute test output
      $stdout.reopen('/dev/null')
      $stderr.reopen('/dev/null')
      FakeSignalFlow.new(host, port, writer).run
      exit
    else
      # original proc
      writer.close
      server_pid = pid
      if !wait_for_port_to_open(host, port)
        fail 'Fake SignalFlow server failed to start!'
      end
    end
  end

  before(:each) do
    client = SignalFxClient.new 'GOOD_TOKEN', :stream_endpoint => "wss://#{host}:#{port}"
    sf = client.signalflow()
  end

  after(:each) do
    sf = nil
  end

  after(:all) do
    if server_pid
      # Kill it with INT to give it a chance to cleanup, if that matters
      Process.kill("INT", server_pid)
    end
  end

  it 'should authenticate before sending messages' do
    sf.execute("data('cpu.utilization').publish()")

    wait_for_notice(reader, AUTH_DONE_MESSAGE)
  end

  it 'should raise exception if auth is bad' do
    client = SignalFxClient.new 'BAD_TOKEN', :stream_endpoint => "wss://#{host}:#{port}"
    sf = client.signalflow()

    expect{ sf.execute("data('cpu.utilization').publish()") }.to raise_error(RuntimeError)
  end

  describe("Execute") do
    it 'should yield received channel messages to block of channel' do
      messages = wait_for_messages(3) do |cb|
        sf.execute("data('cpu.utilization').publish()").each_message_async(&cb)
      end

      expect(messages.length).to be > 2
      expect(messages[0][:type]).to eq("control-message")
      expect(messages[2][:type]).to eq("metadata")
    end

    it 'should not yield messages for another channel to block of execute()' do
      got_bad_message_on_first = false
      sf.execute("data('cpu.utilization').publish()").each_message_async do |msg, detach|
        if msg[:channel] != "channel-1"
          got_bad_message_on_first = true
        end
      end

      wait_for_notice(reader, EXECUTE_DONE_MESSAGE)

      messages = wait_for_messages(1) do |cb|
        sf.execute("data('cpu.utilization').publish()").each_message_async(&cb)
      end

      expect(messages.length).to be > 1
      expect(got_bad_message_on_first).to be(false)
    end

    it 'should decompress binary data messages correctly' do
      program = "data('cpu.utilization').publish()"
      messages = wait_for_messages(EXECUTE[program].length) do |cb|
        sf.execute(program).each_message_async(&cb)
      end

      data_messages = messages.select {|m| m[:type] == "data"}
      expect(data_messages.length).to be > 0
      expect(data_messages[0][:data][0][:timeseries_id]).to eq 467354735
    end

    it 'should decompress binary json messages correctly' do
      program = "data('cpu.utilization').publish()"
      messages = wait_for_messages(EXECUTE[program].length) do |cb|
        sf.execute(program).each_message_async(&cb)
      end

      expect(messages.length).to be > 0
      expect(messages[1][:type]).to eq "control-message"
    end

    it 'should detach from computation when second arg of block is called' do
      messages = []
      # Use the synchronous iterator so we don't have to wait for timeout
      sf.execute("data('cpu.utilization').publish()").each_message do |msg, detach|
        messages << msg
        if msg[:event] == "JOB_START"
          detach.call
        end
      end

      expect(messages.length).to eq(2)
      expect(messages[0][:type]).to eq("control-message")
    end

    it 'should return a computation object with an active channel' do
      c = sf.execute("data('cpu.utilization').publish()")

      expect(c.handle).to eq("DIW1ClNAcAA")
    end

    it 'should stop computation when stop method of computation is called' do
      program = "data('cpu.utilization').publish()"
      comp = sf.execute(program)

      messages = wait_for_messages(EXECUTE[program].length) do |cb|
        comp.each_message_async(&cb)
      end

      comp.stop

      wait_for_notice(reader, ABORT_DONE_MESSAGE)

      expect(messages.length).to be > 0
      Timeout::timeout(1) do
        while !messages.find {|m| m[:event] == "CHANNEL_ABORT"}
        end
      end
      expect(comp.attached?).to be(false)
    end
  end

  describe("Preflight") do
    it 'should yield received channel messages to block of preflight()' do
      messages = wait_for_messages(2) do |cb|
        sf.preflight("detect(data('cpu.utilization') > 70).publish()", 1503799830000, 1503799840000).each_message_async(&cb)
      end

      expect(messages.length).to be > 0
      expect(messages[0][:type]).to eq("control-message")
    end
  end

end
