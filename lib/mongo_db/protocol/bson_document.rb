# frozen_string_literal: true

require 'bindata'
require 'bson'
require 'stringio'

module MongoDB
  module Protocol
    class BSONReader < BinData::Record
      endian :little
      int32  :document_length
      string :document_body, length: -> { document_length - 4 }
    end

    class BSONDocument < BinData::BasePrimitive
      def value_to_binary_string(value)
        value.to_bson.to_s
      end

      def read_and_return_value(io)
        raw_bytes = BSONReader.read(io).to_binary_s
        buffer = BSON::ByteBuffer.new(raw_bytes)
        BSON::Document.from_bson(buffer, mode: :bson)
      rescue StandardError => e
        raise IOError, "Invalid BSON: #{e.inspect}"
      end
    end
  end
end
