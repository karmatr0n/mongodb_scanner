# frozen_string_literal: true

require 'simplecov'
require 'simplecov-json'

SimpleCov.formatters =
  SimpleCov::Formatter::MultiFormatter.new([
                                             SimpleCov::Formatter::HTMLFormatter,
                                             SimpleCov::Formatter::JSONFormatter
                                           ])
SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest-spec-context'
require 'mocha/minitest'
require 'rbkb'
require File.expand_path('../lib/mongo_db', __dir__)

Minitest::Reporters.use!
