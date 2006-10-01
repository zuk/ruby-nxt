#!/usr/bin/env ruby -w
# example code showing how to make a socket server to communicate with nxt
# To use it via telnet:
#   telnet localhost 3001
#   type forward then enter

require File.dirname(File.expand_path(__FILE__))+'/../lib/nxt_comm'
require "socket"

$DEBUG = true

@port = (ARGV[0] || 3001).to_i
@server = TCPServer.new('localhost', @port)
@nxt = NXTComm.new('/dev/tty.NXT-DevB-1')

@move = Commands::Move.new(@nxt)

puts "Ready."

while (@session = @server.accept)
  
  @request = @session.gets
  
  puts "Request: #{@request}"

  case @request.chomp
    when "forward"
      @move.start
    when "stop"
      @move.stop
    else
      @session.puts "Unknown request: #{@request}"
  end
  
  @session.close
  
end
