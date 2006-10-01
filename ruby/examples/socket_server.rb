#!/usr/bin/env ruby -w
#
# example code showing how to make a socket server to communicate with nxt
#
# Copyright (C) 2006 Tony Buser <tbuser@gmail.com> - http://juju.org
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

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
