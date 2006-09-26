#!/usr/bin/env ruby -w

# TODO this should really be placed in the interactive tests directory...

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

  t.action = :bumped
  
  while t.logic == false
    puts "Now bump the button (push and let go)"
    sleep(0.5)
  end
  
  puts "Bumped!"
end

def do_sound_sensor
  s = Commands::SoundSensor.new(@nxt)
  s.comparison = ">"
  s.trigger_point = 30
  
  puts "Sound level: #{s.sound_level}"
  puts "Raw value: #{s.raw_value}"
  
  while s.logic == false
    sleep(0.25)
    puts "Make some noise so sound level is #{s.comparison} #{s.trigger_point}..."
    puts "Sound level: #{s.sound_level}"
  end
  
  puts "Be quiet!"
end

def do_light_sensor
  l = Commands::LightSensor.new(@nxt)
  l.comparison = ">"
  l.trigger_point = 30
  
  puts "Intensity: #{l.intensity}"
  puts "Raw value: #{l.raw_value}"
  
  while l.logic == false
    sleep(0.25)
    puts "Point at a light so that intesity is #{l.comparison} #{l.trigger_point}..."
    puts "Intensity: #{l.intensity}"
  end
  
  puts "I see light!"
  
  puts "Turning off led..."
  
  l.generate_light = false
  
  puts "Normalized Value: #{l.value_normal}"
end

def do_rotation_sensor
  r = Commands::RotationSensor.new(@nxt)
  r.comparison = ">"
  r.trigger_point = 50
  
  while r.logic == false
    sleep(0.5)
    puts "Rotate motor #{r.port} #{r.comparison} #{r.trigger_point} degrees"
    puts "Moving: #{r.direction}"
    puts "Degrees: #{r.degrees}"
  end
  
  puts "Done.  We're at #{r.degrees}.  Now I'll reset the sensor so that degrees will be 0... (unless you kept moving after the reset)"
  
  r.reset

  puts "Degrees: #{r.degrees}"
end

do_light_sensor

puts "Finished."
