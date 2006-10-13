#!/usr/bin/env ruby -w
# example drb client

require "drb"

DRb.start_service
@nxt = DRbObject.new(nil, 'druby://localhost:9000')

puts @nxt.connected?
@nxt.play_tone(500,500)
puts @nxt.keep_alive
