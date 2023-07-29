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
    rescue OpenSSL::SSL::SSLError, Errno::ECONNRESET => _exception
      @socket = tcp_socket
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT => _exception
      abort("Connection refused or timed out. Check your connection settings and try again.")
    end

    def write(data)
      @socket.write(data)
    end

    def close_write
      @socket.close_write
    end

    def puts(data)
      @socket.puts(data)
    end

    def gets
      @socket.gets
    end

    def read(size = nil)
      @socket.read(size)
    end

    def close
      @socket.close
    end

    def flush
      @socket.flush
    end

    private

    def ssl_socket
      @context = OpenSSL::SSL::SSLContext.new
      @context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      OpenSSL::SSL::SSLSocket.new(tcp_socket, @context)
    end

    def tcp_socket
      @socket = TCPSocket.open(host, port)
      @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      @socket
    end
  end
end