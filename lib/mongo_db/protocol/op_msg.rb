# frozen_string_literal: true

require 'bindata'
require_relative 'bson_document'

module MongoDB
  module Protocol
    module FlagBits
      CHECKSUM_PRESENT = 0
      MORE_TO_COME = 1
      EXHAUST_ALLOWED = 16
    end

    class FlagBit < BinData::Primitive
      uint32le :bits

      def set(value)
        self.bits = value.is_a?(Array) ? value.map { |item| 2**item }.sum : value
      end

      def get
        bits
      end
    end

    class DocumentSequence < BinData::Record
      endian :little
      int32   :sequence_size
      stringz :identifier
      array   :documents, type: :bson_document, initial_length: :sequence_size
    end

    # https://www.mongodb.com/docs/manual/reference/mongodb-wire-protocol/#std-label-wire-msg-sections
    class DocumentSection < BinData::Record
      endian :little
      uint8  :payload_type

      choice :payload, selection: :payload_type do
        bson_document 0
        document_sequence 1
      end
    end

    # https://www.mongodb.com/docs/manual/reference/mongodb-wire-protocol/#op_msg
    class OpMsg < BinData::Record
      endian :little
      msg_header :header
      flag_bit :flag_bits
      array :sections, type: :document_section, initial_length: 1
      uint32 :checksum, onlyif: -> { flag_bits.bits == (2**FlagBits::CHECKSUM_PRESENT) }
    end
  end
end
