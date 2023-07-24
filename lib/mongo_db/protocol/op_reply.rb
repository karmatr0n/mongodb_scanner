# frozen_string_literal: true

require 'bindata'
require_relative 'bson_document'

module MongoDB
  module Protocol
    # https://www.mongodb.com/docs/manual/reference/mongodb-wire-protocol/#op_reply
    class OpReply < BinData::Record
      endian :little
      msg_header :header
      uint32 :response_flags
      uint64 :cursor_id
      uint32 :starting_from
      uint32 :number_returned
      array :documents, type: :bson_document, initial_length: -> { number_returned }
    end
  end
end
