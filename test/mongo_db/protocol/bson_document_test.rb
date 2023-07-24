# frozen_string_literal: true

require 'test_helper'

describe MongoDB::Protocol::BSONDocument do
  before do
    @bson_doc = MongoDB::Protocol::BSONDocument.new
    @doc_hash = { ismaster: true, maxBsonObjectSize: 16_777_216 }
  end

  describe '#value_to_binary_string' do
    it 'returns a BSON document string when receives a valid hash' do
      assert_equal(@bson_doc.value_to_binary_string(@doc_hash), @doc_hash.to_bson.to_s)
    end

    it 'returns an empty binary string' do
      assert_empty(@bson_doc.value_to_binary_string(nil))
    end
  end

  describe '#read_and_return_value' do
    it 'returns a BSON::Document receives valid binary string' do
      io = BinData::IO::Read.new(@doc_hash.to_bson.to_s)

      assert_instance_of(BSON::Document, @bson_doc.read_and_return_value(io))
    end

    it 'raise an IOError exception when receives an invalid binary string' do
      io = BinData::IO::Read.new(@doc_hash.to_bson.to_s.slice(0, 10))
      assert_raises(IOError) { @bson_doc.read_and_return_value(io) }
    end
  end
end
