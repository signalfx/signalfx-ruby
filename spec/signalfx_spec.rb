require 'spec_helper'

TOKEN = 'myToken'

describe 'SignalFxClient(a.k.a abstract class)' do
  before(:each) do
    @subject = SignalFxClient.new TOKEN
  end


  it 'exception should be thrown when send data' do
    gauges = [{:metric => 'test.cpu', :value => 1}]
    counters = [{:metric => 'cpu_cnt', :value => 2}]

    expect {
      @subject.send(gauges: gauges, counters: counters)
    }.to raise_error(RuntimeError)
  end

  it 'exception should NOT be thrown when send event' do
    event_type = 'deployments'
    version = '12345'
    dimensions =
        {host: 'myhost',
         service: 'myservice',
         instance: 'myinstance'}
    properties = {version: version}

    stub_request(:post, "https://api.signalfx.com/v1/event").
        with(:body => "{\"eventType\":\"deployments\",\"dimensions\":{\"host\":\"myhost\",\"service\":\"myservice\",\"instance\":\"myinstance\"},\"properties\":{\"version\":\"12345\"}}",
             :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send_event(event_type, dimensions: dimensions, properties: properties)
  end
end

describe 'SignalFx(Fabric method)' do
  before(:each) do
    @subject = SignalFx.new TOKEN
  end

  it 'should be instance of ProtoBufSignalFx class' do
    expect(@subject).to be_a ProtoBufSignalFx
  end

  it 'should be created JsonSignalFx client when Protobuf initialize failed' do
    #Mock ProtoBufSignalFx to thrown Excebtion
    ProtoBufSignalFx.stub(:new).and_raise(Exception)

    @subject = SignalFx.new TOKEN

    expect(@subject).to be_a JsonSignalFx
  end
end

describe 'SignalFx(JSON mode)' do
  before(:each) do
    @subject = JsonSignalFx.new TOKEN
  end

  it 'should be instance of SignalFxClient class' do
    expect(@subject).to be_a SignalFxClient
  end

  it 'should be send datapoints with all params' do
    client = JsonSignalFx.new TOKEN, ingest_endpoint: 'https://custom-ingest.endpoint',
                                    api_endpoint: 'https://custom-api.endpoint', timeout: 5,
                                    batch_size: 5, user_agents: ["ua_1", "ua_2"]
    expect(client).to be_a SignalFxClient

    gauges = [{:metric => 'test.cpu', :value => 1}]
    counters = [{:metric => 'cpu_cnt', :value => 2}]

    stub_request(:post, "https://custom-ingest.endpoint/v2/datapoint").
        with(:body => "{\"gauge\":[{\"metric\":\"test.cpu\",\"value\":1}],\"counter\":[{\"metric\":\"cpu_cnt\",\"value\":2}]}",
             :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'signalfx-ruby-client/0.1.0, ua_1, ua_2', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    client.send(gauges: gauges, counters: counters)
    sleep(0.5)
  end

  it 'should be send event with all params' do
    client = JsonSignalFx.new TOKEN, ingest_endpoint: 'https://custom-ingest.endpoint',
                                    api_endpoint: 'https://custom-api.endpoint', timeout: 5,
                                    batch_size: 5, user_agents: ["ua_1", "ua_2"]
    expect(client).to be_a SignalFxClient

     event_type = 'deployments'
    version = '12345'
    dimensions =
        {host: 'myhost',
         service: 'myservice',
         instance: 'myinstance'}
    properties = {version: version}

    stub_request(:post, "https://custom-api.endpoint/v1/event").
        with(:body => "{\"eventType\":\"deployments\",\"dimensions\":{\"host\":\"myhost\",\"service\":\"myservice\",\"instance\":\"myinstance\"},\"properties\":{\"version\":\"12345\"}}",
             :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'signalfx-ruby-client/0.1.0, ua_1, ua_2', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    client.send_event(event_type, dimensions: dimensions, properties: properties)
  end

  it 'should be instance of SignalFxClient class' do
    expect(@subject).to be_a SignalFxClient
  end

  it 'should send correct int value' do
    gauges = [{:metric => 'test.cpu', :value => 1}]
    counters = [{:metric => 'cpu_cnt', :value => 2}]

    stub_request(:post, "https://ingest.signalfx.com/v2/datapoint").
        with(:body => "{\"gauge\":[{\"metric\":\"test.cpu\",\"value\":1}],\"counter\":[{\"metric\":\"cpu_cnt\",\"value\":2}]}",
             :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send(gauges: gauges, counters: counters)
    sleep(0.5)
  end

  it 'should send correct float value' do
    gauges = [{:metric => 'test.cpu', :value => 1.1}]
    counters = [{:metric => 'cpu_cnt', :value => 2.2}]

    stub_request(:post, "https://ingest.signalfx.com/v2/datapoint").
        with(:body => "{\"gauge\":[{\"metric\":\"test.cpu\",\"value\":1.1}],\"counter\":[{\"metric\":\"cpu_cnt\",\"value\":2.2}]}",
             :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send(gauges: gauges, counters: counters)
    sleep(0.5)
  end

  it 'should send correct string value' do
    gauges = [{:metric => 'test.cpu', :value => "111"}]
    counters = [{:metric => 'cpu_cnt', :value => "222"}]

    stub_request(:post, "https://ingest.signalfx.com/v2/datapoint").
        with(:body => "{\"gauge\":[{\"metric\":\"test.cpu\",\"value\":\"111\"}],\"counter\":[{\"metric\":\"cpu_cnt\",\"value\":\"222\"}]}",
             :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send(gauges: gauges, counters: counters)
    sleep(0.5)
  end

  it 'should send correct data with timestamp' do
    gauges = [{:metric => 'test.cpu', :value => 1, :timestamp => 1234567890}]
    counters = [{:metric => 'cpu_cnt', :value => 2, :timestamp => 1234567890}]

    stub_request(:post, "https://ingest.signalfx.com/v2/datapoint").
        with(:body => "{\"gauge\":[{\"metric\":\"test.cpu\",\"value\":1,\"timestamp\":1234567890}],\"counter\":[{\"metric\":\"cpu_cnt\",\"value\":2,\"timestamp\":1234567890}]}",
             :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send(gauges: gauges, counters: counters)
    sleep(0.5)
  end

  it 'should send correct data with dimensions' do
    gauges = [{:metric => 'test.cpu', :value => 1, :dimensions => [{:key => 'host', :value => 'server1'}, {:key => 'host_ip', :value => '1.2.3.4'}]}]
    counters = [{:metric => 'cpu_cnt', :value => 2, :dimensions => [{:key => 'host', :value => 'server1'}, {:key => 'host_ip', :value => '1.2.3.4'}]}]

    stub_request(:post, "https://ingest.signalfx.com/v2/datapoint").
        with(:body => "{\"gauge\":[{\"metric\":\"test.cpu\",\"value\":1,\"dimensions\":[{\"key\":\"host\",\"value\":\"server1\"},{\"key\":\"host_ip\",\"value\":\"1.2.3.4\"}]}],\"counter\":[{\"metric\":\"cpu_cnt\",\"value\":2,\"dimensions\":[{\"key\":\"host\",\"value\":\"server1\"},{\"key\":\"host_ip\",\"value\":\"1.2.3.4\"}]}]}",
             :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send(gauges: gauges, counters: counters)
    sleep(0.5)

  end

  it 'should send event' do
    event_type = 'deployments'
    version = '12345'
    dimensions =
        {host: 'myhost',
         service: 'myservice',
         instance: 'myinstance'}
    properties = {version: version}

    stub_request(:post, "https://api.signalfx.com/v1/event").
        with(:body => "{\"eventType\":\"deployments\",\"dimensions\":{\"host\":\"myhost\",\"service\":\"myservice\",\"instance\":\"myinstance\"},\"properties\":{\"version\":\"12345\"}}",
             :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send_event(event_type, dimensions: dimensions, properties: properties)
  end


end


describe 'SignalFx(Protobuf mode)' do
  before(:each) do
    @subject = ProtoBufSignalFx.new TOKEN
  end

  it 'should be instance of SignalFxClient class' do
    expect(@subject).to be_a SignalFxClient
  end

  it 'should be send datapoints with all params' do
    client = ProtoBufSignalFx.new TOKEN, ingest_endpoint: 'https://custom-ingest.endpoint',
                                    api_endpoint: 'https://custom-api.endpoint', timeout: 5,
                                    batch_size: 5, user_agents: ["ua_1", "ua_2"]
    expect(client).to be_a SignalFxClient

    gauges = [{:metric => 'test.cpu', :value => 1}]
    counters = [{:metric => 'cpu_cnt', :value => 2}]

    stub_request(:post, "https://custom-ingest.endpoint/v2/datapoint").
        with(:body => "\n\x10\x12\btest.cpu\"\x02\x18\x01(\x00\n\x0F\x12\acpu_cnt\"\x02\x18\x02(\x01",
             :headers => {'Content-Type' => 'application/x-protobuf', 'User-Agent' => 'signalfx-ruby-client/0.1.0, ua_1, ua_2', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    client.send(gauges: gauges, counters: counters)
    sleep(0.5)
  end

  it 'should be send datapoints with all params async' do
    client = ProtoBufSignalFx.new TOKEN, ingest_endpoint: 'https://custom-ingest.endpoint',
                                  api_endpoint: 'https://custom-api.endpoint', timeout: 5,
                                  batch_size: 5, user_agents: ["ua_1", "ua_2"]
    expect(client).to be_a SignalFxClient

    gauges = [{:metric => 'test.cpu', :value => 1}]
    counters = [{:metric => 'cpu_cnt', :value => 2}]

    stub_request(:post, "https://custom-ingest.endpoint/v2/datapoint").
        with(:body => "\n\x10\x12\btest.cpu\"\x02\x18\x01(\x00\n\x0F\x12\acpu_cnt\"\x02\x18\x02(\x01",
             :headers => {'Content-Type' => 'application/x-protobuf', 'User-Agent' => 'signalfx-ruby-client/0.1.0, ua_1, ua_2', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    client.send_async(gauges: gauges, counters: counters)
    sleep(0.5)
  end

  it 'should be send event with all params' do
    client = ProtoBufSignalFx.new TOKEN, ingest_endpoint: 'https://custom-ingest.endpoint',
                                    api_endpoint: 'https://custom-api.endpoint', timeout: 5,
                                    batch_size: 5, user_agents: ["ua_1", "ua_2"]
    expect(client).to be_a SignalFxClient

    event_type = 'deployments'
    version = '12345'
    dimensions =
        {host: 'myhost',
         service: 'myservice',
         instance: 'myinstance'}
    properties = {version: version}

    stub_request(:post, "https://custom-api.endpoint/v1/event").
        with(:body => "{\"eventType\":\"deployments\",\"dimensions\":{\"host\":\"myhost\",\"service\":\"myservice\",\"instance\":\"myinstance\"},\"properties\":{\"version\":\"12345\"}}",
             :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'signalfx-ruby-client/0.1.0, ua_1, ua_2', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    client.send_event(event_type, dimensions: dimensions, properties: properties)
  end

  it 'should send correct int value' do
    gauges = [{:metric => 'test.cpu', :value => 1}]
    counters = [{:metric => 'cpu_cnt', :value => 2}]

    stub_request(:post, "https://ingest.signalfx.com/v2/datapoint").
        with(:body => "\n\x10\x12\btest.cpu\"\x02\x18\x01(\x00\n\x0F\x12\acpu_cnt\"\x02\x18\x02(\x01",
             :headers => {'Content-Type' => 'application/x-protobuf', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send(gauges: gauges, counters: counters)
    sleep(0.5)
  end

  it 'should send correct float value' do
    gauges = [{:metric => 'test.cpu', :value => 1.1}]
    counters = [{:metric => 'cpu_cnt', :value => 2.2}]

    stub_request(:post, "https://ingest.signalfx.com/v2/datapoint").
        with(:headers => {'Content-Type'=>'application/x-protobuf', 'User-Agent'=>'signalfx-ruby-client/0.1.0', 'X-Sf-Token'=>'myToken'}).
        to_return(:status => 200, :body => "OK")

    @subject.send(gauges: gauges, counters: counters)
    sleep(0.5)
  end

  it 'should send correct string value' do
    gauges = [{:metric => 'test.cpu', :value => "111"}]
    counters = [{:metric => 'cpu_cnt', :value => "111"}]

    stub_request(:post, "https://ingest.signalfx.com/v2/datapoint").
        with(:body => "\n\x13\x12\btest.cpu\"\x05\n\x03111(\x00\n\x12\x12\acpu_cnt\"\x05\n\x03111(\x01",
             :headers => {'Content-Type' => 'application/x-protobuf', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send(gauges: gauges, counters: counters)
    sleep(0.5)
  end

  it 'should send correct data with timestamp' do
    gauges = [{:metric => 'test.cpu', :value => 1, :timestamp => 1234567890}]
    counters = [{:metric => 'cpu_cnt', :value => 2, :timestamp => 1234567890}]

    stub_request(:post, "https://ingest.signalfx.com/v2/datapoint").
        with(:body => "\n\x16\x12\btest.cpu\x18\xD2\x85\xD8\xCC\x04\"\x02\x18\x01(\x00\n\x15\x12\acpu_cnt\x18\xD2\x85\xD8\xCC\x04\"\x02\x18\x02(\x01",
             :headers => {'Content-Type' => 'application/x-protobuf', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send(gauges: gauges, counters: counters)
    sleep(0.5)
  end


  it 'should send correct data with dimensions' do
    gauges = [{:metric => 'test.cpu', :value => 1, :dimensions => [{:key => 'host', :value => 'server1'}, {:key => 'host_ip', :value => '1.2.3.4'}]}]
    counters = [{:metric => 'cpu_cnt', :value => 2, :dimensions => [{:key => 'host', :value => 'server1'}, {:key => 'host_ip', :value => '1.2.3.4'}]}]

    stub_request(:post, "https://ingest.signalfx.com/v2/datapoint").
        with(:body => "\n5\x12\btest.cpu\"\x02\x18\x01(\x002\x0F\n\x04host\x12\aserver12\x12\n\ahost_ip\x12\a1.2.3.4\n4\x12\acpu_cnt\"\x02\x18\x02(\x012\x0F\n\x04host\x12\aserver12\x12\n\ahost_ip\x12\a1.2.3.4",
             :headers => {'Content-Type' => 'application/x-protobuf', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send(gauges: gauges, counters: counters)
    sleep(0.5)
  end

  it 'should send event' do
    event_type = 'deployments'
    version = '12345'
    dimensions =
        {host: 'myhost',
         service: 'myservice',
         instance: 'myinstance'}
    properties = {version: version}

    stub_request(:post, "https://api.signalfx.com/v1/event").
        with(:body => "{\"eventType\":\"deployments\",\"dimensions\":{\"host\":\"myhost\",\"service\":\"myservice\",\"instance\":\"myinstance\"},\"properties\":{\"version\":\"12345\"}}",
             :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'signalfx-ruby-client/0.1.0', 'X-Sf-Token' => 'myToken'}).
        to_return(:status => 200, :body => "OK", :headers => {})

    @subject.send_event(event_type, dimensions: dimensions, properties: properties)
  end

end