# frozen_string_literal: true

require 'test_helper'
require 'rbkb'
require 'debug'

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
    @binary_stream = '00700000001068656c6c6f00010000000224646200050000007465737400106d617841' \
      '7761697454696d654d5300f401000003746f706f6c6f677956657273696f6e002d0000' \
      '000770726f6365737349640000000000000000000000000112636f756e746572000100' \
      '0000000000000000'
        .unhexify
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
    @binary_stream = '850000000000000000000000dd0700000000010000700000001068656c6c6f00010000' \
      '000224646200050000007465737400106d6178417761697454696d654d5300f4010000' \
      '03746f706f6c6f677956657273696f6e002d0000000770726f6365737349640064adaf' \
      '9f98514a2d00a8e77712636f756e7465720001000000000000000000'
        .unhexify
    op_msg_read = MongoDB::Protocol::OpMsg.read(@binary_stream)
    assert_equal(op_msg_read, @op_msg)
  end

  # it 'reads a valid payload with more_to_come flag_bits for a OpMsg correctly' do
  #   payload = '390100006000000000000000dd0700000200000000240100000869735772697461626c' \
  #     '655072696d617279000103746f706f6c6f677956657273696f6e002d0000000770726f' \
  #     '6365737349640064c09bf0db9879d15bdbbce712636f756e7465720000000000000000' \
  #     '0000106d617842736f6e4f626a65637453697a650000000001106d61784d6573736167' \
  #     '6553697a65427974657300006cdc02106d61785772697465426174636853697a6500a0' \
  #     '860100096c6f63616c54696d65000295d29289010000106c6f676963616c5365737369' \
  #     '6f6e54696d656f75744d696e75746573001e00000010636f6e6e656374696f6e496400' \
  #     '01000000106d696e5769726556657273696f6e0000000000106d617857697265566572' \
  #     '73696f6e001100000008726561644f6e6c790000016f6b00000000000000f03f009300' \
  #     '00006100000060000000dd07000000000000007e000000016f6b000000000000000000' \
  #     '026572726d736700380000006f7065726174696f6e2077617320696e74657272757074' \
  #     '65642062656361757365206120636c69656e7420646973636f6e6e6563746564001063' \
  #     '6f6465001701000002636f64654e616d650011000000436c69656e74446973636f6e6e' \
  #     '6563740000'
  #       .unhexify
  #   op_msg_size = payload.size
  #   op_msgs = []
  #   until op_msg_size.zero? do
  #       op_msg = MongoDB::Protocol::OpMsg.read(payload)
  #       op_msgs.push(op_msg)
  #       payload = payloade.slice(op_msg.to_binary_s.size..)
  #       op_msg_size = payload.size
  #   end
  #   #s = StringIO.new(op_msg.bytes_remaining.to_binary_s)
  #   #op_msg_read = MongoDB::Protocol::OpMsg.read(s)
  # end
end
