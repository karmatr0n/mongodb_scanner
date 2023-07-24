# frozen_string_literal: true

require 'bindata'

module MongoDB
  module Protocol
    # https://www.mongodb.com/docs/manual/reference/mongodb-wire-protocol/#standard-message-header
    class MsgHeader < BinData::Record
      endian :little
      int32  :message_length
      int32  :request_id
      int32  :response_to
      int32  :op_code
    end
  end
end
