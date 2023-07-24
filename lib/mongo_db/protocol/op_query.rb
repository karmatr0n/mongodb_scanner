# frozen_string_literal: true

require 'bindata'
require_relative 'bson_document'

module MongoDB
  module Protocol
    # https://www.mongodb.com/docs/manual/reference/mongodb-wire-protocol/#op_query
    class OpQuery < BinData::Record
      endian :little
      msg_header :header
      int32 :flags
      stringz :collection_name
      int32 :number_to_skip
      int32 :number_to_return
      bson_document :query_msg
    end
  end
end
