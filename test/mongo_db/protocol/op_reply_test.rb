# frozen_string_literal: true

require 'test_helper'

describe MongoDB::Protocol::OpReply do
  before do
    @header_fields = { message_length: 239, request_id: 32, response_to: 0,
                       op_code: MongoDB::Protocol::OpCodes::OP_REPLY }
    @msg_header = MongoDB::Protocol::MsgHeader.new(@header_fields)
    @query_response = {
      'ismaster' => true,
      'maxBsonObjectSize' => 16_777_216,
      'maxMessageSizeBytes' => 48_000_000,
      'maxWriteBatchSize' => 100_000,
      'localTime' => Time.parse('2022-03-30 04:15:27.879 UTC'),
      'logicalSessionTimeoutMinutes' => 30,
      'minWireVersion' => 0,
      'maxWireVersion' => 6,
      'readOnly' => false,
      'ok' => 1.0
    }
    @reply_msg_fields = {
      header: @msg_header, response_flags: 8, cursor_id: 0, starting_from: 0, number_returned: 1, documents: [@query_response]
    }
    @described_class = MongoDB::Protocol::OpReply
    @reply_msg = @described_class.new(@reply_msg_fields)
    @binary_stream = "\xEF\x00\x00\x00 \x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\b\x00\x00\x00\x00\x00\x00\x00" \
                     "\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\xCB\x00\x00\x00\bismaster\x00\x01\x10maxBs" \
                     "onObjectSize\x00\x00\x00\x00\x01\x10maxMessageSizeBytes\x00\x00l\xDC\x02\x10maxWriteBatchSi" \
                     "ze\x00\xA0\x86\x01\x00\tlocalTime\x00\x87\x1E\t\xD9\x7F\x01\x00\x00\x10logicalSessionTimeou" \
                     "tMinutes\x00\x1E\x00\x00\x00\x10minWireVersion\x00\x00\x00\x00\x00\x10maxWireVersion\x00" \
                     "\x06\x00\x00\x00\breadOnly\x00\x00\x01ok\x00\x00\x00\x00\x00\x00\x00\xF0?\x00"
                     .dup
                     .force_encoding('ASCII-8BIT')
  end

  it 'responds to the header attribute' do
    assert_respond_to(@reply_msg, :header)
  end

  it 'returns the assigned value for the header attribute' do
    assert_equal(@reply_msg.header, @msg_header)
  end

  it 'returns an instance of MongoDB::Protocol::MsgHeader' do
    assert_instance_of(MongoDB::Protocol::MsgHeader, @reply_msg.header)
  end

  it 'responds to the response_flags attribute' do
    assert_respond_to(@reply_msg, :response_flags)
  end

  it 'returns the assigned value for the response_flags attribute' do
    assert_equal(@reply_msg.response_flags, @reply_msg_fields[:response_flags])
  end

  it 'responds to the cursor_id attribute' do
    assert_respond_to(@reply_msg, :cursor_id)
  end

  it 'returns the assigned value for the cursor_id attribute' do
    assert_equal(@reply_msg.cursor_id, @reply_msg_fields[:cursor_id])
  end

  it 'responds to the starting_from attribute' do
    assert_respond_to(@reply_msg, :starting_from)
  end

  it 'returns the assigned value for the starting_from attribute' do
    assert_equal(@reply_msg.starting_from, @reply_msg_fields[:starting_from])
  end

  it 'responds to the number_returned attribute' do
    assert_respond_to(@reply_msg, :number_returned)
  end

  it 'returns the assigned value for the number_returned attribute' do
    assert_equal(@reply_msg.number_returned, @reply_msg_fields[:number_returned])
  end

  it 'returns an instance of MongoDB::Protocol::BSONDocument' do
    assert_instance_of(MongoDB::Protocol::BSONDocument, @reply_msg.documents[0])
  end

  it 'returns the expected binary representation' do
    assert_equal(@reply_msg.to_binary_s, @binary_stream)
  end
end
