#!/usr/bin/env ruby -w

require File.dirname(File.expand_path(__FILE__))+'/../lib/nxt_comm'

$DEV = '/dev/tty.NXT-DevB-1'

@nxt = NXTComm.new($DEV)

def do_move
  command = Move.new(@nxt)

  command.ports = :a, :b, :c
  command.direction = :backward
  command.duration = {:seconds => 2}
  command.next_action = :brake

  command.start

  puts "Run State: #{command.run_state.inspect}"
  puts "Tacho Count: #{command.tacho_count.inspect}"

  command.duration = :unlimited
  command.start
  sleep(2)
  command.stop

  puts "Run State: #{command.run_state.inspect}"
  puts "Tacho Count: #{command.tacho_count.inspect}"
  
  command.port = :c
  command.duration = {:degrees => 50}
  command.start
end

def do_motor
  a = Motor.new(@nxt)
  a.port = :a
  a.duration = {:rotations => 1}
  a.control_power = true
  a.start

  puts "Run State: #{a.run_state}"
end

def do_sound
  s = Sound.new(@nxt)
  s.action = :tone
  s.note = "C"
  s.duration = 0.5
  s.wait = true
  s.start

  s.action = :file
  s.file = "Good Job.rso"
  s.repeat = true

  s.start

  sleep(2)

  s.stop
end

def do_touch_sensor
  t = TouchSensor.new(@nxt)
  t.port = 1
  t.action = :pressed
  
  puts "Touch sensor state: #{t.state}"
  
  while t.state == false
    puts "Hold down the button..."
    sleep(0.5)
  end

  puts "Pressed!"

  t.action = :released
  
  while t.state == false
    puts "Let go of the button..."
    sleep(0.5)
  end

  puts "Released!"
end

do_touch_sensor

puts "Finished."