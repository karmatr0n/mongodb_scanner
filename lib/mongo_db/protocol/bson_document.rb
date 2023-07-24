# frozen_string_literal: true

require 'bindata'
require 'bson'

module MongoDB
  module Protocol
    class BSONDocument < BinData::BasePrimitive
      def value_to_binary_string(value)
        value.to_bson.to_s
      end

      def read_and_return_value(io)
        buffer = BSON::ByteBuffer.new(io.read_all_bytes)
        BSON::Document.from_bson(buffer, mode: :bson)
      rescue StandardError => exception
        raise IOError, "Invalid BSON: #{exception.inspect}"
      end
    end
  end
end
