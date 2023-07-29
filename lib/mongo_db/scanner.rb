# frozen_string_literal: true

require 'json'
require_relative 'tcp_client'
require_relative 'helpers/protocol_msg_helper'
require_relative 'helpers/legacy_protocol_msg_helper'

module MongoDB
  class Scanner
    include MongoDB::Helpers::ProtocolMsgHelper
    include MongoDB::Helpers::LegacyProtocolMsgHelper
    include MongoDB::Protocol

    attr_reader :tcp_client, :supports_op_msg

    def initialize(host, port)
      @tcp_client = TCPClient.new(host, port)
      @tcp_client.connect
      @supports_op_msg = false
      @mongo_detected = false
      @summary = {}
    end

    def scan
      handshake!
      if mongo_detected? && supports_op_msg?
        build_info!
        list_databases!
      end
      legacy_scan unless supports_op_msg?
    end

    def legacy_scan
      legacy_handshake!
      if mongo_detected?
        legacy_build_info!
        legacy_list_databases!
      end
    end

    def handshake!
      @tcp_client.write(hello_msg.to_binary_s)
      response = read_op_msgs(@tcp_client, length: 2)
      response.first.sections.each do |section|
        if section.payload['ok'] == 1.0 and section.payload['maxWireVersion'] >= 6
          @summary[:hello] = section.payload.to_h
          @supports_op_msg = true
          @mongo_detected = true
        end
      end
    end

    def build_info!
      response = send_command(build_info_msg.to_binary_s)
      summary_section!(:build_info, response)
    end

    def list_databases!
      response = send_command(list_databases_msg.to_binary_s)
      summary_section!(:databases, response)
    end

    def send_command(payload)
      @tcp_client.write(payload)
      read_op_msgs(@tcp_client)
    end

    def summary_section!(section, response)
      @summary[section.to_sym] = response.first.sections.map(&:payload).to_a.map(&:to_h)
    end

    def legacy_handshake!
      response = send_legacy_command(legacy_hello.to_binary_s)
      response.documents.each do |section|
        if section['ok'] == 1.0 && section['maxWireVersion'] < 6
          @summary[:hello] = section.to_h
          @mongo_detected = true
        end
      end
    end

    def legacy_build_info!
      response = send_legacy_command(legacy_build_info.to_binary_s)
      legacy_summary_section!(:build_info, response)
    end

    def legacy_list_databases!
      response = send_legacy_command(legacy_list_databases.to_binary_s)
      legacy_summary_section!(:databases, response)
    end

    def send_legacy_command(payload)
      @tcp_client.write(payload)
      read_reply_msg(@tcp_client)
    end

    def legacy_summary_section!(section, response)
      @summary[section.to_sym] = response.documents.to_a.map(&:to_h)
    end

    def pretty_summary
      if mongo_detected?
        JSON.pretty_generate(@summary)
      else
        "No MongoDB detected"
      end
    end

    def supports_op_msg?
      @supports_op_msg
    end

    def mongo_detected?
      @mongo_detected
    end
  end
end
