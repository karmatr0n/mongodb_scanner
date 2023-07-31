# frozen_string_literal: true

require 'bson'
require 'bindata'

module MongoDB
  module Helpers
    module ProtocolMsgHelper
      include MongoDB::Protocol

      def hello_msg
        cmd = {
          'hello' => 1,
          '$db' => 'admin',
          'maxAwaitTimeMS' => 5,
          'topologyVersion' => { 'processId' => BSON::ObjectId('000000000000000000000001'), 'counter' => BSON::Int64.new(1) },
          'client' => {
            'application' => {
              'name' => "MongoDB Scanner"
            },
            'driver' => {
              'name' => "MongoDB Scanner",
              'version' => "1.0.0"
            },
            'os' => {
              'type' => RUBY_PLATFORM
            }
          }
        }
        op_msg(sections: [MongoDB::Protocol::DocumentSection.new(payload_type: 0, payload: cmd)])
      end

      def current_op_msg
        cmd = { '$currentOp' => { }, '$db' => 'admin' }
        op_msg(sections: [MongoDB::Protocol::DocumentSection.new(payload_type: 0, payload: cmd)])
      end

      def build_info_msg
        cmd = { 'buildInfo' => 1, '$db' => 'test' }
        op_msg(sections: [MongoDB::Protocol::DocumentSection.new(payload_type: 0, payload: cmd)])
      end

      def list_databases_msg
        cmd = { listDatabases: 1, '$db' => 'admin' }
        op_msg(sections: [MongoDB::Protocol::DocumentSection.new(payload_type: 0, payload: cmd)])
      end

      def msg_header(length)
        MongoDB::Protocol::MsgHeader.new(
          message_length: length, request_id: 0, response_to: 0, op_code: MongoDB::Protocol::OpCodes::OP_MSG
        )
      end

      def op_msg(flag_bits: [MongoDB::Protocol::FlagBits::EXHAUST_ALLOWED], sections: [])
        op_msg = MongoDB::Protocol::OpMsg.new(flag_bits: flag_bits, sections: sections)
        op_msg.header = msg_header(op_msg.to_binary_s.size)
        op_msg
      end

      def read_op_msgs(socket, length: 1)
        obj = BinData::Array.new(:type => :op_msg, initial_length: length)
        obj.read(socket)
      end
    end
  end
end
