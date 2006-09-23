#!/usr/bin/env ruby -w

require File.dirname(File.expand_path(__FILE__))+'/../lib/nxt_comm'

$DEV = '/dev/tty.NXT-DevB-1'

@nxt = NXTComm.new($DEV)

command = Move.new(@nxt)

command.ports = :a, :b
command.direction = :backward
command.duration = {:seconds => 2}
command.next_action = :coast

command.start

puts "Run State: #{command.run_state.inspect}"
puts "Tacho Count: #{command.tacho_count.inspect}"

