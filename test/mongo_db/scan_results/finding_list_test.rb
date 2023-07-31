require 'test_helper'
describe MongoDB::ScanResults::FindingList  do
  before do
    @finding_list = MongoDB::ScanResults::FindingList.new
  end

  it 'should be empty' do
    assert(@finding_list.empty?)
  end

  it 'should not be empty when a finding is added' do
    @finding_list.add('title', 'description')
    assert(!@finding_list.empty?)
  end

  it 'returns the findings as a hash' do
    @finding_list.add('title', 'description')
    assert_equal({ 'title'=> 'description'}, @finding_list.to_h)
  end

  it 'returns the findings as JSON' do
    @finding_list.add('title', 'description')
    expected_json = JSON.pretty_generate(
      { 'title'=> 'description'}.as_extended_json
    )
    assert_equal(expected_json, @finding_list.to_json)
  end
end