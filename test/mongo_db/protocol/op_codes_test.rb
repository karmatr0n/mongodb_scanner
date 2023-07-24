# frozen_string_literal: true

require 'test_helper'

describe MongoDB::Protocol::OpCodes do
  before do
    @described_class = MongoDB::Protocol::OpCodes
  end

  it 'MongoDB::Protocol::OpCodes::OP_REPLY is equal to 1' do
    assert_equal(1, @described_class::OP_REPLY)
  end

  it 'MongoDB::Protocol::OpCodes::OP_UPDATE is equal to 2001' do
    assert_equal(2001, @described_class::OP_UPDATE)
  end

  it 'MongoDB::Protocol::OpCodes::OP_INSERT is equal to 2002' do
    assert_equal(2002, @described_class::OP_INSERT)
  end

  it 'MongoDB::Protocol::OpCodes::RESERVED is equal to 2003' do
    assert_equal(2003, @described_class::RESERVED)
  end

  it 'MongoDB::Protocol::OpCodes::OP_QUERY is equal to 2004' do
    assert_equal(2004, @described_class::OP_QUERY)
  end

  it 'MongoDB::Protocol::OpCodes::OP_GET_MORE is equal to 2005' do
    assert_equal(2005, @described_class::OP_GET_MORE)
  end

  it 'MongoDB::Protocol::OpCodes::OP_DELETE is equal to 2006' do
    assert_equal(2006, @described_class::OP_DELETE)
  end

  it 'MongoDB::Protocol::OpCodes::OP_KILL_CURSORS is equal to 2007' do
    assert_equal(2007, @described_class::OP_KILL_CURSORS)
  end

  it 'MongoDB::Protocol::OpCodes::OP_COMPRESSED is equal to 2012' do
    assert_equal(2012, @described_class::OP_COMPRESSED)
  end

  it 'MongoDB::Protocol::OpCodes::OP_MSG is equal to 2013' do
    assert_equal(2013, @described_class::OP_MSG)
  end
end
