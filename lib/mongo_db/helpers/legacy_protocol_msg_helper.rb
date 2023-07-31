# frozen_string_literal: true

require 'bindata'

module MongoDB
  module Helpers
    module LegacyProtocolMsgHelper
      include MongoDB::Protocol

      def legacy_hello
        msg_op_query({ isMaster: 1, helloOk: true })
      end

      def legacy_build_info
        msg_op_query({ buildInfo: 1 })
      end
      def legacy_list_databases
        msg_op_query({ listDatabases: 1 })
      end

      def legacy_msg_header(length, op_code = MongoDB::Protocol::OpCodes::OP_QUERY)
        MongoDB::Protocol::MsgHeader.new(
          message_length: length, request_id: 0, response_to: 0, op_code: op_code
        )
      end

      def msg_op_query(cmd)
        query_msg = MongoDB::Protocol::OpQuery.new(
          flags: 0,
          collection_name: 'test.$cmd',
          number_to_skip: 0,
          number_to_return: -1,
          query_msg: cmd
        )
        query_msg.header = legacy_msg_header(query_msg.to_binary_s.size)
        query_msg
      end

      def read_reply_msg(socket)
        MongoDB::Protocol::OpReply.read(socket)
      end
    end
  end
end