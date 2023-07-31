require 'test_helper'

describe MongoDB::ScanResults::Finding do
  before do
    @title = 'title'
    @description ='description'
    @finding = MongoDB::ScanResults::Finding.new(@title, @description)
  end

  it 'has a title' do
    assert_equal(@title, @finding.title)
  end

  it 'has a description' do
    assert_equal(@description, @finding.description)
  end

  it 'can be converted to a hash' do
    assert_equal({ title: @title, description: @description }, @finding.to_h)
  end
end