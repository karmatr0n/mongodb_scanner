# frozen_string_literal: true

module MongoDB
  module Helpers
    module UtilsProtocolMsgHelper
      def msg_header(message_length, op_code: MongoDB::Protocol::OpCodes::OP_MSG)
        MongoDB::Protocol::MsgHeader.new(
          message_length:, request_id: 0, response_to: 0, op_code:
        )
      end

      def op_msg(flag_bits: [MongoDB::Protocol::FlagBits::EXHAUST_ALLOWED], sections: [])
        op_msg = MongoDB::Protocol::OpMsg.new(flag_bits:, sections:)
        op_msg.header = msg_header(op_msg.to_binary_s.size)
        op_msg
      end

      def msg_op_query(cmd)
        query_msg = MongoDB::Protocol::OpQuery.new(
          flags: 0,
          collection_name: 'test.$cmd',
          number_to_skip: 0,
          number_to_return: -1,
          query_msg: cmd
        )
        query_msg.header = msg_header(query_msg.to_binary_s.size, op_code: MongoDB::Protocol::OpCodes::OP_QUERY)
        query_msg
      end
    end
  end
end
