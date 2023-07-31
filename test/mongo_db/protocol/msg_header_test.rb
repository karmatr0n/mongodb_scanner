# frozen_string_literal: true

require 'test_helper'

describe MongoDB::Protocol::MsgHeader do
  before do
    @described_class = MongoDB::Protocol::MsgHeader
    @header_fields = { message_length: 239, request_id: 32, response_to: 0,
                       op_code: MongoDB::Protocol::OpCodes::OP_REPLY }
    @msg_header = @described_class.new(@header_fields)
    @binary_stream = 'ef000000200000000000000001000000'.unhexify
  end

  it 'responds to the message_length attribute' do
    assert_respond_to(@msg_header, :message_length)
  end

  it 'returns the assigned value for the message_length attribute' do
    assert_equal(@msg_header.message_length, @header_fields[:message_length])
  end

  it 'responds to the request_id attribute' do
    assert_respond_to(@msg_header, :request_id)
  end

  it 'returns the assigned value for the request_id attribute' do
    assert_equal(@msg_header.request_id, @header_fields[:request_id])
  end

  it 'responds to the response_to attribute' do
    assert_respond_to(@msg_header, :response_to)
  end

  it 'returns the assigned value for the response_to attribute' do
    assert_equal(@msg_header.response_to, @header_fields[:response_to])
  end

  it 'responds to the op_code attribute' do
    assert_respond_to(@msg_header, :op_code)
  end

  it 'returns the assigned value for the op_code attribute' do
    assert_equal(@msg_header.op_code, @header_fields[:op_code])
  end

  it 'returns the expected binary representation' do
    assert_equal(@msg_header.to_binary_s, @binary_stream)
  end

  it 'returns a MsgHeader object when reads a valid binary stream' do
    assert_equal(@described_class.read(@binary_stream), @msg_header)
  end

  it 'raises an IOError exception when reads an invalid binary stream' do
    assert_raises(IOError) { @described_class.read("\xEF\x00\x00".dup.force_encoding('ASCII-8BIT')) }
  end
end
