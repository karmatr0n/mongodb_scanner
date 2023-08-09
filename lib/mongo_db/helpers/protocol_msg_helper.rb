# frozen_string_literal: true

require 'bson'
require 'bindata'
require_relative 'utils_protocol_msg_helper'

module MongoDB
  module Helpers
    module ProtocolMsgHelper
      include MongoDB::Helpers::UtilsProtocolMsgHelper

      def hello_msg
        cmd = {
          'hello' => 1,
          '$db' => 'admin',
          'maxAwaitTimeMS' => 5,
          'topologyVersion' => { 'processId' => BSON::ObjectId('000000000000000000000001'), 'counter' => BSON::Int64.new(1) },
          'client' => {
            'application' => {
              'name' => 'MongoDB Scanner'
            },
            'driver' => {
              'name' => 'MongoDB Scanner',
              'version' => '1.0.0'
            },
            'os' => {
              'type' => RUBY_PLATFORM
            }
          }
        }
        op_msg(sections: [document_section(payload: cmd)])
      end

      def current_op_msg
        cmd = { '$currentOp' => {}, '$db' => 'admin' }
        op_msg(sections: [document_section(payload: cmd)])
      end

      def build_info_msg
        cmd = { 'buildInfo' => 1, '$db' => 'test' }
        op_msg(sections: [document_section(payload: cmd)])
      end

      def list_databases_msg
        cmd = { listDatabases: 1, '$db' => 'admin' }
        op_msg(sections: [document_section(payload: cmd)])
      end

      def document_section(payload_type: 0, payload: nil)
        MongoDB::Protocol::DocumentSection.new(payload_type:, payload:)
      end

      def read_op_msgs(socket, length: 1)
        obj = BinData::Array.new(type: :op_msg, initial_length: length)
        obj.read(socket)
      end
    end
  end
end
