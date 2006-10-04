#!/usr/bin/env ruby -w
# example drb client

require "drb"

DRb.start_service
@nxt = DRbObject.new(nil, 'druby://localhost:9000')

puts @nxt.connected?
@nxt.play_tone(500,500)
puts @nxt.keep_alive

# TODO have to figure out how to do this, maybe put the Commands within the NXTComm class
# so you can do a sound = @nxt.sound_command?
# sound = Commands::Sound.new(@nxt)
# sound.start
