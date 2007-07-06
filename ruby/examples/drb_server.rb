#!/usr/bin/env ruby -w
# example code showing how to make a drb server to communicate with nxt
# it also spawns a thread that periodically calls keep_alive to prevent
# the nxt from going to sleep

require "rubygems"
require "drb"
require "thread"
require "nxt_comm"

$DEBUG = false
$DEV = '/dev/tty.NXT-DevB-1'
$SAFE = 1 # disable eval() and friends

class NXTServer
  def initialize(dev=$DEV,port=9000)
    @nxt = NXTComm.new(dev)
    @last_keep_alive = Time.now
    @keep_alive_time = 300

    Thread.new do
      DRb.start_service "druby://localhost:#{port}", @nxt
      puts "NXTServer ready at: #{DRb.uri}"
    end

    Thread.new do
      loop do
        if Time.now - @last_keep_alive > @keep_alive_time / 2
          @keep_alive_time = @nxt.keep_alive / 1000
          puts "Sending next keep alive in #{@keep_alive_time / 2} seconds..."
          @last_keep_alive = Time.now
        end
        # need small sleep time or DRb thread won't have time to fire
        # I can't get it to work if I just sleep the keep_alive interval
        sleep 1 
      end
    end.join # make thread block
  end
end

server = NXTServer.new
