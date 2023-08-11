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
    @binary_stream = 'ef00000020000000000000000100000008000000000000000000000000000000010000' \
                     '00cb0000000869736d61737465720001106d617842736f6e4f626a65637453697a6500' \
                     '00000001106d61784d65737361676553697a65427974657300006cdc02106d61785772' \
                     '697465426174636853697a6500a0860100096c6f63616c54696d6500871e09d97f0100' \
                     '00106c6f676963616c53657373696f6e54696d656f75744d696e75746573001e000000' \
                     '106d696e5769726556657273696f6e0000000000106d61785769726556657273696f6e' \
                     '000600000008726561644f6e6c790000016f6b00000000000000f03f00'
                     .unhexify
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
