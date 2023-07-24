# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/reporters'
require 'simplecov'
require File.expand_path('../lib/mongo_db', __dir__)

SimpleCov.start
Minitest::Reporters.use!
