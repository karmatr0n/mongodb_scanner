# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongo_db/version'

Gem::Specification.new do |spec|
  spec.name          = 'mongo_scanner'
  spec.version       = MongoDB::VERSION
  spec.authors       = ['Alejandro Juarez']
  spec.email         = ['karmatr0n@protonmail.ch']
  spec.summary       = 'A basic MongoDB scan_results'
  spec.description   = ''
  spec.homepage      = 'https://github.com/karmatr0n/mongo_scanner'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.2.2'

  spec.add_runtime_dependency 'bindata'
  spec.add_runtime_dependency 'bson'
  spec.add_runtime_dependency 'openssl'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
