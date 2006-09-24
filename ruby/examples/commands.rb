#!/usr/bin/env ruby -w

require File.dirname(File.expand_path(__FILE__))+'/../lib/nxt_comm'

$DEV = '/dev/tty.NXT-DevB-1'

@nxt = NXTComm.new($DEV)

def do_move
  command = Commands::Move.new(@nxt)

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
  a = Commands::Motor.new(@nxt)
  a.port = :a
  a.duration = {:rotations => 1}
  a.control_power = true
  a.start

  puts "Run State: #{a.run_state}"
end

def do_sound
  s = Commands::Sound.new(@nxt)
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
  t = Commands::TouchSensor.new(@nxt)
  t.port = 1
  t.action = :pressed
  
  puts "Touch sensor logic: #{t.logic}"
  puts "Touch sensor raw_value: #{t.raw_value}"
  
  while t.logic == false
    puts "Hold down the button..."
    sleep(0.5)
  end

  puts "Pressed!"

  t.action = :released
  
  while t.logic == false
    puts "Let go of the button..."
    sleep(0.5)
  end

  puts "Released!"
  
  puts "Touch sensor raw_value: #{t.raw_value}"
end

def do_sound_sensor
  s = Commands::SoundSensor.new(@nxt)
  s.comparison = "<"
  
  puts "Sound level: #{s.sound_level}"
  puts "Raw value: #{s.raw_value}"
  
  while s.logic == false
    sleep(0.5)
    puts "Make some noise so sound level is above 50..."
    puts "Sound level: #{s.sound_level}"
    puts "Raw value: #{s.raw_value}"
  end
  
  puts "Be quiet!"
  puts "Sound level: #{s.sound_level}"
  puts "Raw value: #{s.raw_value}"
end

do_sound_sensor

puts "Finished."
