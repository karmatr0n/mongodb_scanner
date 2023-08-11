# frozen_string_literal: true

require 'test_helper'

describe MongoDB::Protocol::OpQuery do
  before do
    @header_fields = {
      message_length: 55, request_id: 0, response_to: 0, op_code: MongoDB::Protocol::OpCodes::OP_QUERY
    }
    @msg_header = MongoDB::Protocol::MsgHeader.new(@header_fields)
    @query = { '$db' => 'test', ping: 1 }
    @query_msg_fields = {
      header: @msg_header,
      flags: 0,
      collection_name: 'protocol-test',
      number_to_skip: 0,
      number_to_return: 0,
      query_msg: @query
    }
    @described_class = MongoDB::Protocol::OpQuery
    @query_msg = @described_class.new(@query_msg_fields)
    @binary_stream = '370000000000000000000000d40700000000000070726f746f636f6c2d746573740000' \
                     '000000000000001d00000002246462000500000074657374001070696e670001000000' \
                     '00'
                     .unhexify
  end

  it 'responds to the header attribute' do
    assert_respond_to(@query_msg, :header)
  end

  it 'returns the assigned value for the header attribute' do
    assert_equal(@query_msg.header, @msg_header)
  end

  it 'returns an instance of MongoDB::Protocol::MsgHeader' do
    assert_instance_of(MongoDB::Protocol::MsgHeader, @query_msg.header)
  end

  it 'responds to the flags attribute' do
    assert_respond_to(@query_msg, :flags)
  end

  it 'returns the assigned value for the flags attribute' do
    assert_equal(@query_msg.flags, @query_msg_fields[:flags])
  end

  it 'responds to the collection_name attribute' do
    assert_respond_to(@query_msg, :collection_name)
  end

  it 'returns the assigned value for the collection_name attribute' do
    assert_equal(@query_msg.collection_name, @query_msg_fields[:collection_name])
  end

  it 'responds to the number_to_skip attribute' do
    assert_respond_to(@query_msg, :number_to_skip)
  end

  it 'returns the assigned value for the number_to_skip attribute' do
    assert_equal(@query_msg.number_to_skip, @query_msg_fields[:number_to_skip])
  end

  it 'responds to the number_to_return attribute' do
    assert_respond_to(@query_msg, :number_to_return)
  end

  it 'returns the assigned value for the number_to_return attribute' do
    assert_equal(@query_msg.number_to_return, @query_msg_fields[:number_to_return])
  end

  it 'responds to the query_msg attribute' do
    assert_respond_to(@query_msg, :query_msg)
  end

  it 'returns the assigned value for the query_msg attribute' do
    assert_equal(@query_msg.query_msg, @query)
  end

  it 'returns an instance of MongoDB::Protocol::BSONDocument' do
    assert_instance_of(MongoDB::Protocol::BSONDocument, @query_msg.query_msg)
  end
end
