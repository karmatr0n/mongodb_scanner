# frozen_string_literal: true

require 'test_helper'

describe MongoDB::Scanner do
  before do
    @host = '127.0.0.1'
    @port = 27017
    @tcp_client = mock('MongoDB::TCPClient')
    MongoDB::TCPClient.stubs(:new).returns(@tcp_client)
    @findings = mock('MongoDB::ScanResults::FindingList')
    MongoDB::ScanResults::FindingList.stubs(:new).returns(@findings)
    @logger = mock('Logger')
    Logger.stubs(:new).with(STDOUT).returns(@logger)
    @scanner = MongoDB::Scanner.new(@host, @port)
  end

  describe 'object attributes' do
    it 'responds to the tcp_client attribute' do
      assert_respond_to(@scanner, :tcp_client)
    end

    it 'responds to the supports_op_msg attribute' do
      assert_respond_to(@scanner, :supports_op_msg)
    end
  end

  describe '#run!' do
    before do
      @tcp_client.stubs(:connect)
      @tcp_client.stubs(:ssl_enabled).returns(true)
      @scanner.stubs(:perform_scan)
      @scanner.stubs(:perform_legacy_scan)
      @findings.stubs(:add)
    end

    it 'connects to the MongoDB service' do
      @tcp_client.expects(:connect)
      @scanner.run!
    end

    it 'adds the ssl_enabled finding to the findings' do
      @findings.expects(:add).with(:ssl_enabled, true)
      @scanner.run!
    end

    it 'performs the scan_results' do
      @scanner.expects(:perform_scan)
      @scanner.run!
    end

    it 'performs the legacy scan_results' do
      @scanner.instance_variable_set(:@supports_op_msg, false)
      @scanner.expects(:perform_legacy_scan)
      @scanner.run!
    end
  end

  describe '#perform_scan' do
    before do
      @scanner.stubs(:handshake!)
      @scanner.stubs(:mongo_detected?).returns(true)
      @scanner.stubs(:supports_op_msg?).returns(true)
      @scanner.stubs(:build_info!)
      @scanner.stubs(:list_databases!)
    end

    it 'performs the handshake' do
      @scanner.expects(:handshake!)
      @scanner.perform_scan
    end

    it 'builds the build info' do
      @scanner.expects(:build_info!)
      @scanner.perform_scan
    end

    it 'lists the databases' do
      @scanner.expects(:list_databases!)
      @scanner.perform_scan
    end

    it 'does not get the build info or databases if MongoDB was not detected' do
      @scanner.stubs(:mongo_detected?).returns(false)
      @scanner.expects(:build_info!).never
      @scanner.expects(:list_databases!).never
      @scanner.perform_scan
    end

    it 'does not get the build info or databases if OpMS is not supported' do
      @scanner.stubs(:supports_op_msg?).returns(false)
      @scanner.expects(:build_info!).never
      @scanner.expects(:list_databases!).never
      @scanner.perform_scan
    end
  end

  describe '#perform_legacy_scan' do
    before do
      @scanner.stubs(:legacy_handshake!)
      @scanner.stubs(:mongo_detected?).returns(true)
      @scanner.stubs(:legacy_build_info!)
      @scanner.stubs(:legacy_list_databases!)
    end

    it 'performs the legacy handshake' do
      @scanner.expects(:legacy_handshake!)
      @scanner.perform_legacy_scan
    end

    it 'builds the build info with legacy command' do
      @scanner.expects(:legacy_build_info!)
      @scanner.perform_legacy_scan
    end

    it 'lists the databases with legacy command' do
      @scanner.expects(:legacy_list_databases!)
      @scanner.perform_legacy_scan
    end

    it 'does not get the build info or databases if MongoDB was not detected' do
      @scanner.stubs(:mongo_detected?).returns(false)
      @scanner.expects(:legacy_build_info!).never
      @scanner.expects(:legacy_build_info!).never
      @scanner.perform_legacy_scan
    end
  end

  describe '#handshake!' do
    before do
      @hello_msg = mock('MongoDB::Protocol::OpMsg')
      @hello_resp = mock('MongoDB::Protocol::OpMsg')
      @section = mock('MongoDB::Protocol::DocumentSection')
      @response = [@hello_msg]
      @hello_msg.stubs(:to_binary_s).returns(@hello_msg)
      @tcp_client.stubs(:write).returns(@hello_resp)
      @scanner.stubs(:read_op_msgs).with(@tcp_client, length: 2).returns(@response)
      @hello_msg.stubs(:sections).returns([@section])
      @section.stubs(:payload).returns({ 'ok' => 1.0, 'maxWireVersion' => 6 })
      @findings.stubs(:add)
    end

    it 'sends a hello message to the MongoDB service' do
      @tcp_client.expects(:write).returns(@hello_resp)
      @scanner.handshake!
    end

    it 'reads the response from the MongoDB service' do
      @scanner.expects(:read_op_msgs).with(@tcp_client, length: 2).returns(@response)
      @scanner.handshake!
    end

    it 'adds the hello response to the findings' do
      @findings.expects(:add).with(:mongo_detected, true)
      @scanner.handshake!
    end

    it 'logs a warning when the handshake response is invalid' do
      @scanner.stubs(:read_op_msgs).with(@tcp_client, length: 2).raises(IndexError)
      @logger.expects(:warn).with('Invalid response for handshake based on OP_MSG')
      @findings.expects(:add).with(:mongo_detected, false)
      @scanner.handshake!
    end
  end

  describe '#parse_hello_response' do
    before do
      @hello = { 'ok' => 1.0, 'maxWireVersion' => 6 }
      @findings.stubs(:add)
    end

    it 'detects mongodb with supports for OpMsg' do
      @documents = [@hello, { 'ok' => 0.0, 'code' => 13 }]
      @scanner.parse_hello_response(@documents)
      assert(@scanner.mongo_detected?)
      assert(@scanner.supports_op_msg?)
    end

    it 'detects mongodb without support for OpMsg' do
      @hello['maxWireVersion'] = 5.1
      @scanner.parse_hello_response([@hello, { 'ok' => 0.0, 'code' => 13 }])
      assert(@scanner.mongo_detected?)
      assert(!@scanner.supports_op_msg?)
    end

    it 'does not detect mongodb' do
      @scanner.parse_hello_response([{ 'ok' => 0.0, 'code' => 13 }])
      assert(!@scanner.mongo_detected?)
      assert(!@scanner.supports_op_msg?)
    end
  end

  describe '#parse_hello_section' do
    before do
      @section = {
        'ok' => 1.0,
        'maxWireVersion' => 6
      }
      @findings.stubs(:add).with(:hello, @section)
    end

    it 'sets mongo as detected and with supports for OpMsg' do
      @scanner.parse_hello_section(@section)
      assert(@scanner.mongo_detected?)
      assert(@scanner.supports_op_msg?)
    end

    it 'detects mongodb without support for OpMsg' do
      @section['maxWireVersion'] = 5.1
      @scanner.parse_hello_section(@section)
      assert(@scanner.mongo_detected?)
      assert(!@scanner.supports_op_msg?)
    end

    it 'adds the hello response to the findings' do
      @findings.expects(:add).with(:hello, @section)
      @scanner.parse_hello_section(@section)
    end
  end

  describe '#build_info!' do
    before do
      @cmd = mock('MongoDB::Protocol::OpMsg')
      @binary_stream = ('binary string')
      @cmd.stubs(:to_binary_s).returns(@binary_stream)
      @scanner.stubs(:build_info_msg).returns(@cmd)
      @tcp_client.stubs(:write).with(@binary_stream)

      @section = mock('MongoDB::Protocol::DocumentSection')
      @payload = { 'ok' => 1.0, 'maxWireVersion' => 6 }
      @section.stubs(:payload).returns(@payload)
      @response = mock('MongoDB::Protocol::OpMsg')
      @response.stubs(:sections).returns([@section])
      @scanner.stubs(:read_op_msgs).with(@tcp_client).returns([@response])
      @findings.stubs(:add)
    end

    it 'sends a command to the MongoDB service' do
      @tcp_client.expects(:write).with(@binary_stream)
      @scanner.build_info!
    end

    it 'reads the response from the MongoDB service' do
      @scanner.expects(:read_op_msgs).with(@tcp_client).returns([@response])
      @scanner.build_info!
    end

    it 'add the response to the findings' do
      @findings.expects(:add).with(:build_info, [@payload])
      @scanner.build_info!
    end
  end

  describe '#list_database!' do
    before do
      @cmd = mock('MongoDB::Protocol::OpMsg')
      @binary_stream = ('binary string')
      @cmd.stubs(:to_binary_s).returns(@binary_stream)
      @scanner.stubs(:list_databases_msg).returns(@cmd)
      @tcp_client.stubs(:write).with(@binary_stream)

      @section = mock('MongoDB::Protocol::DocumentSection')
      @payload = { 'ok' => 1.0, 'maxWireVersion' => 6 }
      @section.stubs(:payload).returns(@payload)
      @response = mock('MongoDB::Protocol::OpMsg')
      @response.stubs(:sections).returns([@section])
      @scanner.stubs(:read_op_msgs).with(@tcp_client).returns([@response])
      @findings.stubs(:add)
    end

    it 'sends a command to the MongoDB service' do
      @tcp_client.expects(:write).with(@binary_stream)
      @scanner.list_databases!
    end

    it 'reads the response from the MongoDB service' do
      @scanner.expects(:read_op_msgs).with(@tcp_client).returns([@response])
      @scanner.list_databases!
    end

    it 'add the response to the findings' do
      @findings.expects(:add).with(:databases, [@payload])
      @scanner.list_databases!
    end
  end

  describe '#send_command!' do
    before do
      @cmd = mock('MongoDB::Protocol::OpMsg')
      @response = mock('MongoDB::Protocol::OpMsg')
    end

    it 'sends a command to the MongoDB service' do
      @tcp_client.expects(:write).with(@cmd)
      @scanner.stubs(:read_op_msgs).with(@tcp_client).returns(@response)
      @scanner.send_command!(@cmd)
    end

    it 'reads the response from the MongoDB service' do
      @tcp_client.stubs(:write).with(@cmd)
      @scanner.expects(:read_op_msgs).with(@tcp_client).returns(@response)
      assert_equal(@response, @scanner.send_command!(@cmd))
    end
  end

  describe '#add_findings!' do
    before do
      @section = mock('MongoDB::Protocol::DocumentSection')
      @payload = { 'ok' => 1.0, 'maxWireVersion' => 6 }
      @section.stubs(:payload).returns(@payload)
      @response = mock('MongoDB::Protocol::OpMsg')
      @response.stubs(:sections).returns([@section])
    end

    it 'adds the findings to the findings' do
      @findings.expects(:add).with(:hello, [@payload])
      @scanner.add_finding!(:hello, @response)
    end
  end

  describe '#legacy_handshake!' do
    before do
      @hello_msg = mock('MongoDB::Protocol::OpQuery')
      @binary_stream = ('binary string')
      @hello_msg.stubs(:to_binary_s).returns(@binary_stream)
      @scanner.stubs(:legacy_hello).returns(@hello_msg)
      @tcp_client.stubs(:write).returns(@binary_stream)
      @payload = { 'ok' => 1.0, 'maxWireVersion' => 5 }
      @response = mock('MongoDB::Protocol::OpReply')
      @response.stubs(:documents).returns([@payload])
      @scanner.stubs(:read_reply_msg).with(@tcp_client).returns(@response)
      @findings.stubs(:add)
    end

    it 'sends a hello message to the MongoDB service' do
      @tcp_client.expects(:write).returns(@hello_resp)
      @scanner.legacy_handshake!
    end

    it 'reads the response from the MongoDB service' do
      @scanner.expects(:read_reply_msg).with(@tcp_client).returns(@response)
      @scanner.legacy_handshake!
    end

    it 'adds the hello response to the findings' do
      @findings.expects(:add)
      @scanner.legacy_handshake!
    end

    it 'logs a warning when the handshake response is invalid' do
      @scanner.stubs(:read_reply_msg).with(@tcp_client).raises(Errno::EPIPE)
      @logger.expects(:warn).with('Invalid response received for handshake based on OP_QUERY')
      @findings.expects(:add).with(:mongo_detected, false)
      @scanner.legacy_handshake!
    end
  end

  describe '#legacy_build_info!' do
    before do
      @cmd = mock('MongoDB::Protocol::OpQuery')
      @binary_stream = ('binary string')
      @cmd.stubs(:to_binary_s).returns(@binary_stream)
      @scanner.stubs(:legacy_build_info).returns(@cmd)
      @tcp_client.stubs(:write).returns(@binary_stream)
      @payload = { 'ok' => 1.0, 'maxWireVersion' => 5 }
      @response = mock('MongoDB::Protocol::OpReply')
      @response.stubs(:documents).returns([@payload])
      @scanner.stubs(:read_reply_msg).with(@tcp_client).returns(@response)
      @findings.stubs(:add)
    end

    it 'sends a build_info message to the MongoDB service' do
      @tcp_client.expects(:write).returns(@hello_resp)
      @scanner.legacy_build_info!
    end

    it 'reads the response from the MongoDB service' do
      @scanner.expects(:read_reply_msg).with(@tcp_client).returns(@response)
      @scanner.legacy_build_info!
    end

    it 'adds the hello response to the findings' do
      @findings.expects(:add).with(:build_info, [@payload])
      @scanner.legacy_build_info!
    end
  end

  describe '#legacy_build_info!' do
    before do
      @cmd = mock('MongoDB::Protocol::OpQuery')
      @binary_stream = ('binary string')
      @cmd.stubs(:to_binary_s).returns(@binary_stream)
      @scanner.stubs(:legacy_list_databases).returns(@cmd)
      @tcp_client.stubs(:write).returns(@binary_stream)
      @payload = { 'ok' => 1.0, 'maxWireVersion' => 5 }
      @response = mock('MongoDB::Protocol::OpReply')
      @response.stubs(:documents).returns([@payload])
      @scanner.stubs(:read_reply_msg).with(@tcp_client).returns(@response)
      @findings.stubs(:add)
    end

    it 'sends a build_info message to the MongoDB service' do
      @tcp_client.expects(:write).returns(@hello_resp)
      @scanner.legacy_list_databases!
    end

    it 'reads the response from the MongoDB service' do
      @scanner.expects(:read_reply_msg).with(@tcp_client).returns(@response)
      @scanner.legacy_list_databases!
    end

    it 'adds the hello response to the findings' do
      @findings.expects(:add).with(:databases, [@payload])
      @scanner.legacy_list_databases!
    end
  end

  describe '#send_legacy_command!' do
    before do
      @cmd = mock('MongoDB::Protocol::OpQuery')
      @response = mock('MongoDB::Protocol::OpReply')
    end

    it 'sends a command to the MongoDB service' do
      @tcp_client.expects(:write).with(@cmd)
      @scanner.stubs(:read_reply_msg).with(@tcp_client).returns(@response)
      @scanner.send_legacy_command!(@cmd)
    end

    it 'reads the response from the MongoDB service' do
      @tcp_client.stubs(:write).with(@cmd)
      @scanner.expects(:read_reply_msg).with(@tcp_client).returns(@response)
      assert_equal(@response, @scanner.send_legacy_command!(@cmd))
    end
  end

  describe '#findings_to_json' do
    before do
      @pretty_findings = { results: "pretty findings" }.to_json
    end

    it 'returns a formatted string of the findings' do
      @findings.stubs(:to_json).returns(@pretty_findings)
      assert_equal(@pretty_findings, @scanner.findings_to_json)
    end
  end

  describe '#legacy_add_finding!' do
    before do
      @payload = { 'ok' => 1.0, 'maxWireVersion' => 6 }
      @response = mock('MongoDB::Protocol::OpReply')
      @response.stubs(:documents).returns([@payload])
    end

    it 'adds the findings to the findings' do
      @findings.expects(:add).with(:hello, [@payload])
      @scanner.legacy_add_finding!(:hello, @response)
    end
  end

  describe '#supports_op_msg?' do
    it 'returns true if the MongoDB service supports OpMsg message protocols' do
      @scanner.instance_variable_set(:@supports_op_msg, true)
      assert(@scanner.supports_op_msg?)
    end

    it 'returns false if the MongoDB service supports OpMsg message protocol is not supported' do
      assert(!@scanner.supports_op_msg?)
    end
  end

  describe '#mongo_detected?' do
    it 'returns true if the MongoDB service is detected' do
      @scanner.instance_variable_set(:@mongo_detected, true)
      assert(@scanner.mongo_detected?)
    end

    it 'returns false if the MongoDB service is not detected' do
      assert(!@scanner.mongo_detected?)
    end
  end
end