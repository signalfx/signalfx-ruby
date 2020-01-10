# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/signalfx/version'

Gem::Specification.new do |spec|
  spec.name          = "signalfx"
  spec.version       = SignalFx::Version::VERSION
  spec.authors       = ["SignalFx, Inc"]
  spec.email         = ["info@signalfx.com"]

  spec.summary       = "Ruby client library for SignalFx"
  spec.description   = "This is a programmatic interface in Ruby for SignalFx's metadata and ingest APIs. It is meant to provide a base for communicating with SignalFx APIs that can be easily leveraged by scripts and applications to interact with SignalFx or report metric and event data to SignalFx. Library supports Ruby 2.2.x+ versions"
  spec.homepage      = "https://signalfx.com"
  spec.license       = "Apache Software License v2 © SignalFx"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  #if spec.respond_to?(:metadata)
  #  spec.metadata['allowed_push_host'] = "Set to 'http://mygemserver.com'"
  #else
  #  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  #end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_development_dependency "bundler", "~> 1.17.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "webmock", "~> 2.3.1"
  spec.add_development_dependency "thin", "~> 1.7"
  spec.add_development_dependency "pry"

  # protobuf enforces this check but builds with a newer Ruby version so it's not enabled.
  # Incorporating here to allow 2.2.0-1 users to successfully build and install signalfx.
  active_support_max_version = Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.2.2") ? "<5" : "<6"
  spec.add_dependency "activesupport", '>= 3.2', active_support_max_version

  spec.add_dependency "protobuf", ">= 3.5.1"
  spec.add_dependency "rest-client", "~> 2.0"
  spec.add_dependency "faye-websocket", "~> 0.10.7"
  spec.add_dependency "i18n", "= 1.1.0"
  spec.add_dependency "thor", "= 0.20.0"

end
