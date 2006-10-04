#!/usr/bin/env ruby -w
# example code showing how to make a drb server to communicate with nxt

require File.dirname(File.expand_path(__FILE__))+'/../lib/nxt_comm'
require 'drb'

$DEBUG = true
$DEV = '/dev/tty.NXT-DevB-1'
$SAFE = 1 # disable eval() and friends

class NXTComm
  # SerialPort can't be marshalled
  include DRbUndumped
end

class NXTServer
  private_class_method :new
  @@nxts = {}

  def NXTServer.connect(dev=$DEV)
    # TODO have to fix NXTComm#connected? since it returns true even if NXT turns off
    if !@@nxts[dev] or !@@nxts[dev].connected?
      @@nxts[dev] = NXTComm.new(dev)
    end
    @@nxts[dev]
  end
end

# TODO is this even possible?
# keepalive_thread = Thread.new do
#   nxt = server.connect
#   sleep_time = nxt.keep_alive
#   puts "Sending keep alive in #{sleep_time / 2000} seconds..."
#   sleep(sleep_time / 2000)
# end

DRb.start_service 'druby://localhost:9000', NXTServer.connect
puts DRb.uri
DRb.thread.join
