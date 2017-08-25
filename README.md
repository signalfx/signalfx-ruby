# Ruby client library for SignalFx

This is a programmatic interface in Ruby for SignalFx's metadata and
ingest APIs. It is meant to provide a base for communicating with
SignalFx APIs that can be easily leveraged by scripts and applications
to interact with SignalFx or report metric and event data to SignalFx.

This library supports Ruby versions 2.2.x and above.

## Installation

Add this line to your application's Gemfile:

    gem 'signalfx'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install signalfx

## Usage

### API access token

To use this library, you need a SignalFx API access token, which can be obtained from the SignalFx organization you want to report data into.

### Create client

The default constructor `SignalFx` uses Protobuf to send data to SignalFx. If it cannot send Protobuf, it falls back to sending JSON.

```ruby
require('signalfx')

// Create client
client = SignalFx.new 'MY_SIGNALFX_TOKEN'
```

Optional constructor parameters:
+ **api_token** (string): your private SignalFx token.
+ **enable_aws_unique_id** (boolean): `false` by default.
  If `true`, the library will retrieve the Amazon instance unique
  identifier and set it as `AWSUniqueId` dimension for each
  datapoint and event. Use this option only if your application is
  deployed on Amazon AWS.
+ **ingest_endpoint** (string): to override the target ingest API
  endpoint.
+ **api_endpoint** (string): to override the target REST API endpoint.
+ **timeout** (number): timeout, in seconds, for requests to SignalFx.
+ **batch_size** (number): size of datapoint batches to send to
  SignalFx.
+ **user_agents** (array of strings): an array of additional User-Agent
  strings to use when making requests to SignalFx.

### Reporting data

This example shows how to report metrics to SignalFx, as gauges, counters, or cumulative counters.

```ruby
require('signalfx')

client = SignalFx.new 'MY_SIGNALFX_TOKEN'

client.send(
           cumulative_counters:[
             {  :metric => 'myfunc.calls_cumulative',
                :value => 10,
                :timestamp => 1442960607000 },
             ...
           ],
           gauges:[
             {  :metric => 'myfunc.time',
                :value => 532,
                :timestamp => 1442960607000},
             ...
           ],
           counters:[
             {  :metric => 'myfunc.calls',
                :value => 42,
                :timestamp => 1442960607000},
             ...
           ])
```

The `timestamp` must be a millisecond precision timestamp; the number of
milliseconds elapsed since Epoch. The `timestamp` field is optional, but
strongly recommended. If not specified, it will be set by SignalFx's
ingest servers automatically; in this situation, the timestamp of your
datapoints will not accurately represent the time of their measurement
(network latency, batching, etc. will all impact when those datapoints
actually make it to SignalFx).

### Sending multi-dimensional data

Reporting dimensions for the data is also optional, and can be
accomplished by specifying a `dimensions` parameter on each datapoint
containing a dictionary of string to string key/value pairs representing
the dimensions:

```ruby
require('signalfx')

client = SignalFx.new 'MY_SIGNALFX_TOKEN'

client.send(
          cumulative_counters:[
            {   :metric => 'myfunc.calls_cumulative',
                :value => 10,
                :dimensions => [{:key => 'host', :value => 'server1'}]},
            ...
          ],
          gauges:[
            {   :metric => 'myfunc.time',
                :value=> 532,
                :dimensions=> [{:key => 'host', :value => 'server1'}]},
            ...
          ],
          counters:[
            {   :metric=> 'myfunc.calls',
                :value=> 42,
                :dimensions=> [{:key => 'host', :value => 'server1'}]},
            ...
          ])
```

See `examples/generic_usecase.rb` for a complete code example for
reporting data.

### Sending events

Events can be sent to SignalFx via the `send_event()` function. The
event type must be specified, and dimensions and extra event properties
can be supplied as well. Also please specify event category: for that
get option from dictionary `EVENT_CATEGORIES`. Different categories of
events are supported. Available categories of events are `USER_DEFINED`,
`ALERT`, `AUDIT`, `JOB`, `COLLECTD`, `SERVICE_DISCOVERY`, `EXCEPTION`.

```ruby
require('signalfx')

client = SignalFx.new 'MY_SIGNALFX_TOKEN'

client.send_event(
    '[event_type]',
    '[event_category]',
    { host: 'myhost',
      service: 'myservice',
      instance: 'myinstance' },
    properties={ version: 'event_version' },
    timestamp)
```

See `examples/generic_usecase.rb` for a complete code example for
sending events.

### SignalFlow

You can run SignalFlow computations as well.  This library supports all of the
functionality described in our [API docs for
SignalFlow](https://developers.signalfx.com/reference#signalflowconnect). Right
now, the only supported transport mechanism is WebSockets.

To create a new SignalFlow client instance from an existing SignalFx client:

```ruby
sf = client.signalflow()
```

To execute and attach to a SignalFlow computation, do the
following:

```ruby
sf.execute("data('cpu.utilization').mean(by='host').publish()").each_message do |msg, detach|
  case msg[:type]
  when "data"
    process_datapoints(msg.timestamp, msg.data)
  end

  if done_processing
    detach.call
  end
end
```

For the full API see [the RubyDocs for the SignalFlow
client](http://www.rubydoc.info/github/signalfx/signalfx-ruby/master/SignalFlowClient/)
(the `sf` var above).

The messages passed into the `each_message*` blocks will be decoded forms of
what is described in [our API reference for
SignalFlow](https://developers.signalfx.com/v2/reference#information-messages-specification).
Hash keys will be symbols instead of strings.

## License

Apache Software License v2. Copyright © 2015-2016
[SignalFx](https://signalfx.com)
