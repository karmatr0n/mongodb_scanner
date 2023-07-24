# frozen_string_literal: true

require 'test_helper'

describe MongoDB::Protocol::FlagBit do
  before do
    @flag_bit = MongoDB::Protocol::FlagBit.new
  end

  it 'responds to the set method' do
    assert_respond_to(@flag_bit, :set)
  end

  it 'returns the assigned value for the set method' do
    assert_equal(65_536, @flag_bit.set([MongoDB::Protocol::FlagBits::EXHAUST_ALLOWED]))
  end

  it 'responds to the get method' do
    assert_respond_to(@flag_bit, :get)
  end

  it 'returns the assigned value for the get method' do
    @flag_bit.set([MongoDB::Protocol::FlagBits::EXHAUST_ALLOWED])

    assert_equal(65_536, @flag_bit.get)
  end
end

describe MongoDB::Protocol::DocumentSequence do
  before do
    cmd = [
      { _id: 'Document#1', example: 1 },
      { _id: 'Document#2', example: 2 },
      { _id: 'Document#3', example: 3 }
    ]
    @doc_sequence = MongoDB::Protocol::DocumentSequence.new(
      sequence_size: cmd.length,
      identifier: 'documents',
      documents: cmd
    )
  end

  it 'responds to the sequence_size attribute' do
    assert_respond_to(@doc_sequence, :sequence_size)
  end

  it 'responds to the identifier attribute' do
    assert_respond_to(@doc_sequence, :identifier)
  end

  it 'responds to the documents attribute' do
    assert_respond_to(@doc_sequence, :documents)
  end
end

describe MongoDB::Protocol::DocumentSection do
  before do
    payload = {
      'hello' => 1,
      '$db' => 'test',
      'maxAwaitTimeMS' => 500,
      'topologyVersion' => { 'processId' => BSON::ObjectId('000000000000000000000001'), 'counter' => BSON::Int64.new(1) }
    }

    @section = MongoDB::Protocol::DocumentSection.new(
      payload_type: 0, payload:
    )
  end

  it 'responds to the payload_type attribute' do
    assert_respond_to(@section, :payload_type)
  end

  it 'responds to the payload attribute' do
    assert_respond_to(@section, :payload)
  end

  it 'returns an instance of BinData::Choice for the payload' do
    assert_equal(0, @section.payload_type)
    assert_instance_of(BinData::Choice, @section.payload)
  end

  it 'reads a valid payload for a DocumentSection correctly' do
    @binary_stream =  "\x00p\x00\x00\x00\x10hello\x00\x01\x00\x00\x00\x02$db\x00\x05\x00\x00\x00test\x00\x10" \
                      "maxAwaitTimeMS\x00\xF4\x01\x00\x00\x03topologyVersion\x00-\x00\x00\x00\aprocessId\x00" \
                      "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x12counter\x00\x01\x00\x00\x00\x00" \
                      "\x00\x00\x00\x00\x00"
                      .dup
                      .force_encoding('ASCII-8BIT')
    section_read = MongoDB::Protocol::DocumentSection.read(@binary_stream)

    assert_equal(section_read, @section)
  end
end

describe MongoDB::Protocol::OpMsg do
  before do
    @cmd = {
      'hello' => 1,
      '$db' => 'test',
      'maxAwaitTimeMS' => 500,
      'topologyVersion' => { 'processId' => BSON::ObjectId('64adaf9f98514a2d00a8e777'), 'counter' => BSON::Int64.new(1) }
    }

    @sections = [MongoDB::Protocol::DocumentSection.new(payload_type: 0, payload: @cmd)]

    @op_msg = MongoDB::Protocol::OpMsg.new(
      flag_bits: [MongoDB::Protocol::FlagBits::EXHAUST_ALLOWED],
      sections: @sections
    )

    @msg_header = MongoDB::Protocol::MsgHeader.new(
      message_length: @op_msg.to_binary_s.length, request_id: 0, response_to: 0, op_code: MongoDB::Protocol::OpCodes::OP_MSG
    )

    @op_msg.header = @msg_header
  end

  it 'responds to the header attribute' do
    assert_respond_to(@op_msg, :header)
  end

  it 'returns the assigned value for the header attribute' do
    assert_equal(@op_msg.header, @msg_header)
  end

  it 'returns an instance of MongoDB::Protocol::MsgHeader' do
    assert_instance_of(MongoDB::Protocol::MsgHeader, @op_msg.header)
  end

  it 'responds to the flag_bits attribute' do
    assert_respond_to(@op_msg, :flag_bits)
  end

  it 'returns the assigned value for the flag_bits attribute' do
    assert_equal(2**16, @op_msg.flag_bits)
  end

  it 'responds to the sections attribute' do
    assert_respond_to(@op_msg, :sections)
  end

  it 'returns an instance of BinData::Array for the sections attribute' do
    assert_instance_of(BinData::Array, @op_msg.sections)
  end

  it 'returns same object when it reads a binary data stream' do
    @binary_stream = "\x85\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xDD\a\x00\x00\x00\x00\x01\x00\x00p\x00\x00" \
                     "\x00\x10hello\x00\x01\x00\x00\x00\x02$db\x00\x05\x00\x00\x00test\x00\x10maxAwaitTimeMS\x00" \
                     "\xF4\x01\x00\x00\x03topologyVersion\x00-\x00\x00\x00\aprocessId\x00d\xAD\xAF\x9F\x98QJ-\x00" \
                     "\xA8\xE7w\x12counter\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00"
                     .dup
                     .force_encoding('ASCII-8BIT')
    op_msg_read = MongoDB::Protocol::OpMsg.read(@binary_stream)

    assert_equal(op_msg_read, @op_msg)
  end
end
