# Migrate from the SignalFx Tracing Library for Ruby

The SignalFx Tracing Library for Ruby is deprecated. Replace it with the
agent from the Splunk Distribution of OpenTelemetry Ruby.

The agent of the Splunk Distribution of OpenTelemetry Ruby is based on
the OpenTelemetry Instrumentation for Ruby, an open-source project that
uses the OpenTelemetry API.

Read the following instructions to learn how to migrate to the Splunk
Ruby OTel agent.

## Compatibility and requirements

The Splunk Distribution of OpenTelemetry Ruby requires Ruby 2.5 and
higher.

## Migrate to the Splunk Distribution of OpenTelemetry Ruby

To migrate from the SignalFx Tracing Library for Ruby to the Splunk
Distribution of OpenTelemetry Ruby, follow these steps:

1.  Remove the tracing library packages.
2.  Deploy the Splunk Distribution of OpenTelemetry Ruby.
3.  Migrate your existing configuration.

> Semantic conventions for span names and attributes change when you
migrate.

### Remove the SignalFx Tracing Library for Ruby

Follow these steps to remove the tracing library and its dependencies:

1.  Uninstall `signalfx`:

    ``` bash
    gem uninstall signalfx
    ```

2.  Remove `signalfx` from your Gemfile.

3.  Remove any additional OpenTracing instrumentation packages you
    installed.

### Deploy the Splunk Ruby agent

To install the Splunk Distribution of OpenTelemetry Ruby, see the [README.md](README.md).

### Migrate settings for the Splunk Ruby OTel agent

To migrate settings from the SignalFx tracing library to the Splunk
Distribution of OpenTelemetry Ruby, rename the following environment
variables:

| SignalFx environment variable        | OpenTelemetry environment variable                               |
|--------------------------------------|------------------------------------------------------------------|
| `SIGNALFX_ACCESS_TOKEN`              | `SPLUNK_ACCESS_TOKEN`                                            |
| `SIGNALFX_SERVICE_NAME`              | `OTEL_SERVICE_NAME`                                              |
| `SIGNALFX_ENDPOINT_URL`              | `OTEL_EXPORTER_JAEGER_ENDPOINT` or `OTEL_EXPORTER_OTLP_ENDPOINT` |
| `SIGNALFX_RECORDED_VALUE_MAX_LENGTH` | `SPLUNK_MAX_ATTR_LENGTH`                                         |

For more information about Splunk Ruby OTel settings, see [advanced-config.md](docs/advanced-config.md).
