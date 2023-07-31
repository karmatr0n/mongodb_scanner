# frozen_string_literal: true

module MongoDB
  module ScanResults
    class Finding
      attr_reader :title, :description

      def initialize(title, description)
        @title = title
        @description = description
      end

      def to_h
        { title:, description: }
      end
    end
  end
end
