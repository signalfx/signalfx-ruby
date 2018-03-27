$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require './lib/signalfx'

token = ARGV[0] # Your SignalFx API access token
if token.nil? || token.empty?
  puts '
        SignalFx API access token not defined. Please specify token in command line.
            $ ./signalflow.rb YOUR_TOKEN

        '
  exit 0
end


#create client instance with SignalFx API access token
client = SignalFx.new(token, enable_aws_unique_id: false, timeout: 3000)

puts 'SignalFlow demo:'
puts

signalflow = client.signalflow()

signalflow.execute("data('cpu.utilization').publish()").each_message do |msg, comp|
  unless msg.nil?
    case msg[:type]
    when "data"
      puts "#{'Host'.center(40, ' ')} | cpu.utilization"
      msg[:data].each do |tsid,value|
        puts "#{comp.metadata[tsid][:host][0..40].center(40, ' ')} | #{value}"
      end
    end
  end
  puts ""
end
