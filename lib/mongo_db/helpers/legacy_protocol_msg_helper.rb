# frozen_string_literal: true

require_relative 'utils_protocol_msg_helper'

module MongoDB
  module Helpers
    module LegacyProtocolMsgHelper
      include MongoDB::Helpers::UtilsProtocolMsgHelper

      def legacy_hello
        msg_op_query({ isMaster: 1, helloOk: true })
      end

      def legacy_build_info
        msg_op_query({ buildInfo: 1 })
      end

      def legacy_list_databases
        msg_op_query({ listDatabases: 1 })
      end

      def read_reply_msg(socket)
        MongoDB::Protocol::OpReply.read(socket)
      end
    end
  end
end
