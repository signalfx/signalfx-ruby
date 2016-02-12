# Ruby client library for SignalFx

This is a programmatic interface in Ruby for SignalFx's metadata and ingest APIs. It is meant to provide a base for communicating with SignalFx APIs that can be easily leveraged by scripts and applications to interact with SignalFx or report metric and event data to SignalFx.
Library supports Ruby 2.x versions

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
+ **api_token** - Your private SignalFx token
+ **enable_aws_unique_id** - boolean, `false` by default.
       If `true`, library will retrieve Amazon unique identifier
       and set it as `AWSUniqueId` dimension for each datapoint and event.
       Use this option only if your application deployed to Amazon
+ **ingest_endpoint** - string
+ **api_endpoint** - string
+ **timeout** - number
+ **batch_size** - number
+ **user_agents** - array

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
The `timestamp` must be a millisecond precision timestamp; the number of milliseconds elapsed since Epoch. The `timestamp` field is optional, but strongly recommended. If not specified, it will be set by SignalFx's ingest servers automatically; in this situation, the timestamp of your datapoints will not accurately represent the time of their measurement (network latency, batching, etc. will all impact when those datapoints actually make it to SignalFx).

### Sending multi-dimensional data

Reporting dimensions for the data is also optional, and can be accomplished by specifying a `dimensions` parameter on each datapoint containing a dictionary of string to string key/value pairs representing the dimensions:


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
See `examples/generic_usecase.rb` for a complete code example for Reporting data.

### Sending events

Events can be sent to SignalFx via the `send_event` function. The
event type must be specified, and dimensions and extra event properties
can be supplied as well. Also please specify event category: for that get
option from dictionary `EVENT_CATEGORIES`. Different categories of events are supported.
Available categories of events are `USER_DEFINED`, `ALERT`, `AUDIT`, `JOB`, 
`COLLECTD`, `SERVICE_DISCOVERY`, `EXCEPTION`. 

```ruby
require('signalfx')

client = SignalFx.new 'MY_SIGNALFX_TOKEN'

client.send_event(
          '[event_type]',
          '[event_category]',
          {
              host: 'myhost',
              service: 'myservice',
              instance: 'myinstance'
          },
          properties={
              version: 'event_version'},
          timestamp)
```

See `examples/generic_usecase.rb` for a complete code example for Reporting data.

## License

Apache Software License v2 © [SignalFx](https://signalfx.com)
