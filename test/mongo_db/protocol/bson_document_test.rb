# frozen_string_literal: true

require 'test_helper'

describe MongoDB::Protocol::BSONReader do
  before do
    @binary_stream =
      '930000006100000060000000dd07000000000000007e000000016f6b00000000' \
      '0000000000026572726d736700380000006f7065726174696f6e207761732069' \
      '6e7465727275707465642062656361757365206120636c69656e742064697363' \
      '6f6e6e65637465640010636f6465001701000002636f64654e616d6500110000' \
      '00436c69656e74446973636f6e6e6563740000'.unhexify
    @bson_reader = MongoDB::Protocol::BSONReader.read(@binary_stream)
  end

  it 'responds to the document_length attribute' do
    assert_respond_to(@bson_reader, :document_length)
  end

  it 'responds to the document_body attribute' do
    assert_respond_to(@bson_reader, :document_body)
  end

  it 'the document_length attribute is equal to 147' do
    assert_equal(147, @bson_reader.document_length)
  end

  it 'the document_body attribute size is equal to 143' do
    assert_equal(143, @bson_reader.document_body.size)
  end
end

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
