# frozen_string_literal: true

require 'test_helper'
describe MongoDB::ScanResults::FindingList do
  before do
    @finding_list = MongoDB::ScanResults::FindingList.new
  end

  it 'should be empty' do
    assert_empty(@finding_list)
  end

  it 'should not be empty when a finding is added' do
    @finding_list.add('title', 'description')

    refute_empty(@finding_list)
  end

  it 'returns the findings as a hash' do
    @finding_list.add('title', 'description')

    assert_equal({ 'title' => 'description' }, @finding_list.to_h)
  end

  it 'returns the findings as JSON' do
    @finding_list.add('title', 'description')
    expected_json = JSON.pretty_generate(
      { 'title' => 'description' }.as_extended_json
    )

    assert_equal(expected_json, @finding_list.to_json)
  end
end
