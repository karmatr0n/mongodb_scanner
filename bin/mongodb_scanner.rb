# frozen_string_literal: true
#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path(File.join('..', '..', '/lib'), __FILE__)
require 'optparse'
require 'ostruct'
require 'mongo_db'

options = OpenStruct.new
OptionParser.new do |opts|
  opts.banner = 'Usage: mongodb_scanner -i <HOST> -p <PORT>'
  opts.on('-i', '--host [HOST]', String, 'The hostname  or ip_address')
  opts.on('-p', '--port [PORT]', Integer, 'The destination port')
end.parse!(into: options)

options.port = 27017 if options.port.nil?
raise OptionParser::MissingArgument.new('--host') if options.host.nil?

scanner = MongoDB::Scanner.new(options.host, options.port)
scanner.scan
puts scanner.pretty_summary
