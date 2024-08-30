>ℹ️&nbsp;&nbsp;SignalFx was acquired by Splunk in October 2019. See [Splunk SignalFx](https://www.splunk.com/en_us/investor-relations/acquisitions/signalfx.html) for more information.

# Ruby client library for SignalFx

# :warning:This repository and its published libraries are deprecated

This repository contains legacy libraries for reporting metrics to Splunk 
Observability Cloud (formerly SignalFx). The only commits that will be made 
to this repo are organizational or security related patches. No additional 
features will be added, and the repository will be archived and the final 
versions published on or prior to March 1, 2025.

# :warning:This repo will be archived March 1st 2025.

Splunk has adopted OpenTelemetry. Please visit official documentation page: [Instrument Ruby applications for Splunk Observability Cloud](https://docs.splunk.com/observability/en/gdi/get-data-in/application/ruby/get-started-ruby.html#get-started-ruby). Use [OpenTelemetry Ruby Instrumentation distribution](https://github.com/open-telemetry/opentelemetry-ruby) to send telemetry data to Splunk Observability Cloud. 
Do not integrate `signalfx-ruby` into new services.

## Overview 

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

#### Installing with Ruby 2.2.0 and 2.2.1

This library's protobuf dependency requires activesupport >=3.2.  5.x versions of activesupport require Ruby >=2.2.2,
so users of older Ruby versions will need to install activesupport 4.2.10 before signalfx to avoid attempts of
installing a more recent gem.  Building and installing signalfx from source will fulfill this for you:

    $ gem build signalfx.gemspec && gem install signalfx-<current_version>.gem

## Usage


### Configuring your endpoints

In order to send your data to the correct realm, you may need to configure your
endpoints. If no endpoints are set manually, this library uses the ``us0`` realm by default.
If you are not in this realm, you will need to explicitly set the
endpoint config options below. To determine if you are in a different realm and need to
explicitly set the endpoints, check your profile page in the SignalFx
web application.

```ruby
require('signalfx')
# Create client with alternate ingest endpoint
client = SignalFx.new('ORG_TOKEN', ingest_endpoint: 'https://ingest.{REALM}.signalfx.com',
                      stream_endpoint: 'https:/stream.{REALM}.signalfx.com')

```

### Access tokens

To use this library, you will also need to specify an access token when requesting
one of those clients. For the ingest client, you need to specify your
organization access token (which can be obtained from the
SignalFx organization you want to report data into). For the SignalFlow client, either an
organization access token or a user access token may be used. For more
information on access tokens, see the API's [authentication documentation](https://developers.signalfx.com/basics/authentication.html).


### Create client

The default constructor `SignalFx` uses Protobuf to send data to SignalFx. If it cannot send Protobuf, it falls back to sending JSON.

```ruby
require('signalfx')

# Create client
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
+ **stream_endpoint** (string): to override the target stream endpoint for SignalFlow.
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

#### Reporting data through a HTTP proxy

To send data through a HTTP proxy, set the environment variable `http_proxy`
with the proxy URL.

The SignalFlow client by default will use the proxy set in the `http_proxy`
envvar by default. To send SignalFlow websocket data through a separate proxy,
set the `proxy_url` keyword arg on the `client.signalflow` call.


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

timestamp = (Time.now.to_i * 1000).to_i

client = SignalFx.new 'MY_SIGNALFX_TOKEN'

client.send_event(
    '<event_type>',
    event_category: '<event_category>',
    dimensions: { host: 'myhost',
      service: 'myservice',
      instance: 'myinstance' },
    properties: { version: 'event_version' },
    timestamp: timestamp)
```

See `examples/generic_usecase.rb` for a complete code example for
sending events.

### SignalFlow

You can run SignalFlow computations as well.  This library supports all of the
functionality described in our [API docs for
SignalFlow](https://developers.signalfx.com/signalflow_reference.html). Right
now, the only supported transport mechanism is WebSockets.

#### Configure the SignalFlow client endpoint

By default, this library connects to the `us0` stream endpoint.
If you are not in this realm, you will need to explicitly set the
endpoint config options below when creating the client.
To determine if you are in a different realm and need to
explicitly set the endpoints, check your profile page in the SignalFx web application.

```ruby
client = SignalFx.new(
  'ORG_TOKEN',
  ingest_endpoint: 'https://ingest.{REALM}.signalfx.com',
  stream_endpoint: 'wss://stream.{REALM}.signalfx.com'
)
```


To create a new SignalFlow client instance from an existing SignalFx client:

```ruby
signalflow = client.signalflow()
```

For the full API see [the RubyDocs for
the SignalFlow
client](https://www.rubydoc.info/github/signalfx/signalfx-ruby/master/SignalFlowClient/)
(the `signalflow` var above).

There is also [a demo script](./examples/signalflow.rb) that shows basic usage.

## License

Apache Software License v2. Copyright © 2015-2016
[SignalFx](https://signalfx.com)
