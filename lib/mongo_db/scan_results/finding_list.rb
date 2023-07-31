# frozen_string_literal: true

require 'json'
require_relative 'finding'

module MongoDB
  module ScanResults
    class FindingList
      attr_reader :findings

      def initialize
        @findings = []
      end

      def add(title, description)
        findings << Finding.new(title, description)
      end

      def to_h
        findings.each_with_object({}) do |finding, h|
          h[finding.title] = finding.description
        end
      end

      def to_json
        JSON.pretty_generate(to_h.as_extended_json)
      end

      def empty?
        findings.empty?
      end
    end
  end
end
