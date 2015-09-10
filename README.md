# Ruby client library for SignalFx

This is a programmatic interface in Ruby for SignalFx's metadata and ingest APIs. It is meant to provide a base for communicating with SignalFx APIs that can be easily leveraged by scripts and applications to interact with SignalFx or report metric and event data to SignalFx.
Library supports Ruby 2.x versions

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'signalfx'
```

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
require('signalfx');

// Create client
client = SignalFx.new 'MY_SIGNALFX_TOKEN';
```

### Reporting data

This example shows how to report metrics to SignalFx, as gauges, counters, or cumulative counters. 

```ruby
require('signalfx');

client = SignalFx.new 'MY_SIGNALFX_TOKEN';

client.send(
           cumulative_counters:[
             {metric=> 'myfunc.calls_cumulative', value=> 10},
             ...
           ],
           gauges:[
             {metric=> 'myfunc.time', value=> 532},
             ...
           ],
           counters:[
             {metric=> 'myfunc.calls', value=> 42},
             ...
           ]);
```

Optionally, you can also add dimensions to the metrics, as follows:


```ruby
require('signalfx');

client = SignalFx.new 'MY_SIGNALFX_TOKEN';

client.send(
          cumulative_counters:[
            {'metric'=> 'myfunc.calls_cumulative', 'value'=> 10, 'dimensions'=> {'host'=> 'server1', 'host_ip'=> '1.2.3.4'}},
            ...
          ],
          gauges:[
            {'metric'=> 'myfunc.time', 'value'=> 532, 'dimensions'=> {'host'=> 'server1', 'host_ip'=> '1.2.3.4'}},
            ...
          ],
          counters:[
            {'metric'=> 'myfunc.calls', 'value'=> 42, 'dimensions'=> {'host'=> 'server1', 'host_ip'=> '1.2.3.4'}},
            ...
          ]);
```
See `examples/generic_usecase.py` for a complete code example for Reporting data.

### Sending events

Events can be sent to SignalFx via the `send_event` function. The
event type must be specified, and dimensions and extra event properties
can be supplied as well.


```ruby
require('signalfx');

client = SignalFx.new 'MY_SIGNALFX_TOKEN';

client.send_event(
          '[event_type]',
          {
              host: 'myhost',
              service: 'myservice',
              instance: 'myinstance'
          },
          properties={
              version: 'event_version'})
```

See `examples/generic_usecase.py` for a complete code example for Reporting data.

## License

Apache Software License v2 © [SignalFx](https://signalfx.com)