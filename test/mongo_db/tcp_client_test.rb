# frozen_string_literal: true

require 'test_helper'

describe MongoDB::TCPClient do
  before do
    @host = '127.0.0.1'
    @port = 27_017
    @tcp_client = MongoDB::TCPClient.new(@host, @port)
    @tcp_socket = mock('TCPSocket')
    @ssl_socket = mock('OpenSSL::SSL::SSLSocket')
    @context = mock('OpenSSL::SSL::SSLContext')
    TCPSocket.stubs(:open).with(@host, @port).returns(@tcp_socket)
    @tcp_socket.stubs(:setsockopt).with(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
    OpenSSL::SSL::SSLContext.stubs(:new).returns(@context)
    @context.stubs(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
    OpenSSL::SSL::SSLSocket.stubs(:new).with(@tcp_socket, @context).returns(@ssl_socket)
    @ssl_socket.stubs(:connect)
  end

  describe 'object attributes' do
    it 'responds to the socket attribute' do
      assert_respond_to(@tcp_client, :socket)
    end

    it 'responds to the ssl_enabled attribute' do
      assert_respond_to(@tcp_client, :ssl_enabled)
    end

    it 'responds to the host attribute' do
      assert_respond_to(@tcp_client, :host)
    end

    it 'responds to the port attribute' do
      assert_respond_to(@tcp_client, :port)
    end
  end

  describe '#connect' do
    context 'when the client makes an ssl connection successfully' do
      it 'connects to the ssl service and sets the ssl socket' do
        @ssl_socket.expects(:connect)
        @tcp_client.connect

        assert_equal(@ssl_socket, @tcp_client.socket)
      end

      it 'sets the ssl_enabled to true' do
        @ssl_socket.stubs(:connect)
        @tcp_client.connect

        assert(@tcp_client.ssl_enabled)
      end
    end

    context 'when the client cannot connect via SSL successfully' do
      before do
        @ssl_socket.stubs(:connect).raises(OpenSSL::SSL::SSLError)
        TCPSocket.stubs(:open).with(@host, @port).returns(@tcp_socket)
        @tcp_socket.stubs(:setsockopt).with(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      end

      it 'connects to the service via TCP and sets the socket' do
        @tcp_client.connect

        assert_equal(@tcp_socket, @tcp_client.socket)
      end

      it 'it does not the ssl_enabled as true' do
        @tcp_client.connect

        refute(@tcp_client.ssl_enabled)
      end
    end

    context 'when the client cannot connect via SSL or TCP ' do
      before do
        @ssl_socket.stubs(:connect).raises(OpenSSL::SSL::SSLError)
        TCPSocket.stubs(:open).with(@host, @port).raises(Errno::ECONNREFUSED)
      end

      it 'aborts the client connection' do
        @tcp_client.expects(:abort).with('Connection refused or timed out. Check your connection settings and try again.')
        @tcp_client.connect
      end
    end
  end

  describe '#write' do
    it 'writes data to the socket' do
      @tcp_client.connect
      @ssl_socket.expects(:write).with('test')
      @tcp_client.write('test')
    end
  end

  describe '#read' do
    it 'reads data from the socket' do
      @tcp_client.connect
      @ssl_socket.expects(:read).returns('test')

      assert_equal('test', @tcp_client.read)
    end
  end

  describe '#close' do
    it 'closes the socket' do
      @tcp_client.connect
      @ssl_socket.expects(:close)
      @tcp_client.close
    end
  end

  describe '#ssl_socket' do
    it 'sets the ssl context with none verificatio mode' do
      @context.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
      @tcp_client.ssl_socket
    end

    it 'returns an ssl conext' do
      OpenSSL::SSL::SSLSocket.expects(:new).returns(@ssl_socket)

      assert_equal(@ssl_socket, @tcp_client.ssl_socket)
    end
  end

  describe '#tcp_socket' do
    it 'sets the tcp socket options' do
      @tcp_socket.expects(:setsockopt).with(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      TCPSocket.stubs(:open).with(@host, @port).returns(@tcp_socket)
      @tcp_client.tcp_socket
    end

    it 'returns a tcp socket' do
      @tcp_socket.stubs(:setsockopt).with(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      TCPSocket.expects(:open).with(@host, @port).returns(@tcp_socket)

      assert_equal(@tcp_socket, @tcp_client.tcp_socket)
    end
  end
end
