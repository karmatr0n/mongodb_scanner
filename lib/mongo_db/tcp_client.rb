# frozen_string_literal: true

require 'socket'
require 'openssl'

module MongoDB
  class TCPClient
    attr_reader :socket, :ssl_enabled, :host, :port

    def initialize(host, port)
      @host = host
      @port = port
      @ssl_enabled = false
      @socket = nil
    end

    def connect
      @socket = ssl_socket
      @socket.connect
      @ssl_enabled = true
    rescue OpenSSL::SSL::SSLError, Errno::ECONNRESET => _e
      @socket = tcp_socket
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT => _e
      abort('Connection refused or timed out. Check your connection settings and try again.')
    end

    def write(data)
      @socket.write(data)
    end

    def read(size = nil)
      @socket.read(size)
    end

    def close
      @socket.close
    end

    def ssl_socket
      ssl_context = OpenSSL::SSL::SSLContext.new
      ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      OpenSSL::SSL::SSLSocket.new(tcp_socket, ssl_context)
    end

    def tcp_socket
      @socket = TCPSocket.open(host, port)
      @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      @socket
    end
  end
end
