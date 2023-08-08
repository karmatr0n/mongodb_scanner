# frozen_string_literal: true

require 'logger'
require_relative 'tcp_client'
require_relative 'protocol'
require_relative 'helpers/protocol_msg_helper'
require_relative 'helpers/legacy_protocol_msg_helper'
require_relative 'scan_results/finding_list'

module MongoDB
  class Scanner
    include MongoDB::Helpers::ProtocolMsgHelper
    include MongoDB::Helpers::LegacyProtocolMsgHelper
    include MongoDB::ScanResults

    attr_reader :tcp_client, :supports_op_msg, :findings, :logger

    def initialize(host, port)
      @tcp_client = TCPClient.new(host, port)
      @supports_op_msg = false
      @mongo_detected = false
      @findings = FindingList.new
      @logger = Logger.new(STDOUT)
    end

    def run!
      @tcp_client.connect
      findings.add(:ssl_enabled, @tcp_client.ssl_enabled)
      perform_scan
      perform_legacy_scan unless supports_op_msg?
    end

    def perform_scan
      handshake!
      return unless mongo_detected? && supports_op_msg?

      build_info!
      list_databases!
    end

    def perform_legacy_scan
      legacy_handshake!
      return unless mongo_detected?

      legacy_build_info!
      legacy_list_databases!
    end

    def handshake!
      @tcp_client.write(hello_msg.to_binary_s)
      response = read_op_msgs(@tcp_client, length: 2)
      documents = response.map(&:sections).map { |section| section.map(&:payload) }.flatten
      parse_hello_response(documents)
    rescue IndexError => _e
      logger.warn('Invalid response for handshake based on OP_MSG')
    ensure
      findings.add(:mongo_detected, mongo_detected?)
    end

    def parse_hello_response(documents)
      documents.each do |section|
        parse_hello_section(section) if section['ok'] == 1.0
      end
    end

    def parse_hello_section(section)
      @mongo_detected = true
      @supports_op_msg = true if section['maxWireVersion'] >= 6
      findings.add(:hello, section.to_h)
    end

    def build_info!
      response = send_command!(build_info_msg.to_binary_s)
      add_finding!(:build_info, response.first)
    end

    def list_databases!
      response = send_command!(list_databases_msg.to_binary_s)
      add_finding!(:databases, response.first)
    end

    def send_command!(payload)
      @tcp_client.write(payload)
      read_op_msgs(@tcp_client)
    end

    def add_finding!(section, response_msg)
      findings.add(section, response_msg.sections.map(&:payload).to_a.map(&:to_h))
    end

    def legacy_handshake!
      response = send_legacy_command!(legacy_hello.to_binary_s)
      parse_hello_response(response.documents)
    rescue Errno::EPIPE => _e
      logger.warn('Invalid response received for handshake based on OP_QUERY')
    ensure
      findings.add(:mongo_detected, mongo_detected?)
    end

    def legacy_build_info!
      response = send_legacy_command!(legacy_build_info.to_binary_s)
      legacy_add_finding!(:build_info, response)
    end

    def legacy_list_databases!
      response = send_legacy_command!(legacy_list_databases.to_binary_s)
      legacy_add_finding!(:databases, response)
    end

    def send_legacy_command!(payload)
      @tcp_client.write(payload)
      read_reply_msg(@tcp_client)
    end

    def legacy_add_finding!(section, response_msg)
      findings.add(section, response_msg.documents.map(&:to_h))
    end

    def findings_to_json
      findings.to_json
    end

    def supports_op_msg?
      @supports_op_msg
    end

    def mongo_detected?
      @mongo_detected
    end
  end
end
