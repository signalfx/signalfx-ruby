$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require './lib/signalfx'

puts 'SignalFx metrics reporting demo:'
token = ARGV[0] # Your SignalFx API access token
if token.nil? || token.empty?
  puts '
        SignalFx API access token not defined. Please specify token in command line.
            $ ./generic_usecase.rb YOUR_TOKEN

        '
  exit 0
end


#create client instance with SignalFx API access token
client = SignalFx.new token, enable_aws_unique_id: true, timeout: 3000

puts 'SignalFx metrics reporting demo:'
#run loop to send datapoints to SignalFx
counter = 0
while true do
  puts "Send datapoints ##{counter}"
  timestamp = (Time.now.to_i * 1000).to_i
  gauges = [{:metric => 'test.cpu', :value => counter % 10, :timestamp => timestamp}]
  counters = [{:metric => 'cpu_cnt', :value => counter % 2, :timestamp => timestamp}]

  client.send(gauges: gauges, counters: counters)

  if counter % 100 == 0
    event_type = 'deployments'
    version = Time.now.strftime("%Y-%m-%d") + '-' + counter.to_s
    dimensions =
        {host: 'myhost',
         service: 'myservice',
         instance: 'myinstance'}
    properties = {version: version}


    client.send_event(event_type, dimensions: dimensions, properties: properties)
  end

  counter +=1
  sleep(1)
end