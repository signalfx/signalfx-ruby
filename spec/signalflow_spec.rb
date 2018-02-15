require 'socket'

require 'timeout'
require 'spec_helper'

require_relative './fake_signalflow/server'
require_relative './fake_signalflow/util'

TOKEN = 'mytoken'

# Wait until the computation that is executed in the block gives `count`
# messages.  The computation done in the block must use async iteration of
# messages to make timeouts work.
def wait_for_messages(count=1, timeout=10, &block)
  lock = Mutex.new
  message_cv = ConditionVariable.new
  messages = []

  yield ->(msg, comp){
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

describe 'SignalFlow (Websocket)' do
  host = '127.0.0.1'
  port = 23456
  sf = nil
  kill_server = nil
  reader = nil

  before(:all) do
    kill_server, reader = start_fake(host, port, use_ssl: false)
  end

  before(:each) do
    client = SignalFxClient.new 'GOOD_TOKEN', :stream_endpoint => "ws://#{host}:#{port}"
    sf = client.signalflow()
  end

  after(:each) do
    sf = nil
  end

  after(:all) do
    kill_server.call if kill_server
  end

  it 'should authenticate before sending messages' do
    sf.execute("data('cpu.utilization').publish()")

    wait_for_notice(reader, AUTH_DONE_MESSAGE)
  end

  it 'should raise exception if auth is bad' do
    client = SignalFxClient.new 'BAD_TOKEN', :stream_endpoint => "ws://#{host}:#{port}"
    sf = client.signalflow()

    expect{ sf.execute("data('cpu.utilization').publish()") }.to raise_error(RuntimeError)
  end

  describe("Execute") do
    it 'should yield received channel messages to block of channel' do
      messages = wait_for_messages(2) do |cb|
        sf.execute("data('cpu.utilization').publish()").each_message_async(&cb)
      end

      expect(messages.length).to be >= 2
      expect(messages[0][:type]).to eq("metadata")
      expect(messages[0][:tsId]).to eq("AAAAAEgCVmg")
    end

    it 'should not yield messages for another channel to block of execute()' do
      got_bad_message_on_first = false
      sf.execute("data('cpu.utilization').publish()").each_message_async do |msg, comp|
        if msg[:channel] != "channel-1"
          got_bad_message_on_first = true
        end
      end

      wait_for_notice(reader, EXECUTE_DONE_MESSAGE)

      messages = wait_for_messages(1) do |cb|
        sf.execute("data('cpu.utilization').publish()").each_message_async(&cb)
      end

      expect(messages.length).to be >= 1
      expect(got_bad_message_on_first).to be(false)
    end

    it 'should decompress binary data messages correctly' do
      messages = wait_for_messages(2) do |cb|
        sf.execute("data('cpu.utilization').publish()").each_message_async(&cb)
      end

      data_messages = messages.select {|m| m[:type] == "data"}
      expect(data_messages.length).to be > 0
      expect(data_messages[0][:data]["AAAAABvbRG8"]).to eq(1.9999999925494194)
    end

    it 'should decompress binary json messages correctly' do
      program = "data('cpu.utilization').publish()"
      messages = wait_for_messages(2) do |cb|
        sf.execute(program).each_message_async(&cb)
      end

      expect(messages.length).to be > 0
      expect(messages[0][:type]).to eq "metadata"
    end

    it 'should detach from computation when detach on computation is called' do
      messages = []
      # Use the synchronous iterator so we don't have to wait for timeout
      sf.execute("data('cpu.utilization').publish()").each_message do |msg, comp|
        messages << msg
        comp.detach
      end

      expect(messages.length).to eq(1)
      expect(messages[0][:type]).to eq("metadata")
    end

    it 'should return a computation object with an active channel' do
      c = sf.execute("data('cpu.utilization').publish()")

      expect(c.handle).to eq("DIW1ClNAcAA")
    end

    it 'should stop computation when stop method of computation is called' do
      program = "data('cpu.utilization').publish()"
      comp = sf.execute(program)

      done = false
      Timeout::timeout(5) do
        comp.each_message do |msg|
          comp.stop
          wait_for_notice(reader, ABORT_DONE_MESSAGE)
        end
        done = true
      end
      expect(done).to be(true)
      expect(comp.attached?).to be(false)
    end

    it 'should cache metadata about timeseries' do
      comp = sf.execute("data('cpu.utilization').publish()")
      wait_for_messages(2) do |cb|
        comp.each_message_async(&cb)
      end

      expect(comp.metadata["AAAAAEgCVmg"][:plugin]).to eq("signalfx-metadata")
    end

    it 'should handle batches of data with more than one message per batch' do
      program = "data('cpu.utilization').publish(); data('if_octets.rx').publish()"
      comp = sf.execute(program)

      messages = []
      comp.each_message_async do |msg|
        messages << msg
      end

      Timeout::timeout(5) do
        while !(messages.select {|m| m[:type] == "data"}.length == 3)
          sleep 0.5
        end
      end
    end
  end

  describe("Preflight") do
    it 'should yield received channel messages to block of preflight()' do
      messages = wait_for_messages(1) do |cb|
        sf.preflight("detect(data('cpu.utilization') > 70).publish()", 1503799830000, 1503799840000).each_message_async(&cb)
      end

      expect(messages.length).to be > 0
      expect(messages[0][:type]).to eq("metadata")
    end
  end

  describe("SSL Verification") do
    ssl_port = 23443
    kill_server = nil

    before(:all) do
      kill_server, reader = start_fake(host, ssl_port, use_ssl: true)
    end

    after(:all) do
      kill_server.call if kill_server
    end

    # A lot of the Ruby WebSocket clients turn verification off by default for
    # some reason.  The fake server uses a self-signed cert so verification
    # should fail.
    it 'should verify the peer when using a TLS socket' do
      client = SignalFxClient.new 'GOOD_TOKEN', :stream_endpoint => "wss://#{host}:#{ssl_port}"
      sf = client.signalflow()

      expect{ sf.execute("data('cpu.utilization').publish()") }.to raise_error(OpenSSL::SSL::SSLError)
    end
  end

end
