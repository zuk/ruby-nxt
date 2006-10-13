require File.dirname(__FILE__) + '/../test_helper'
require "commands"
require "interactive_test_helper"

include InteractiveTestHelper

require "autodetect_nxt"

info "Connecting to the NXT at #{$DEV}..."

begin
  $nxt = NXTComm.new($DEV)
rescue
  fail "Could not connect to the NXT!"
  fail "The error was: #{$!}"
  notice "Make sure that the NXT is turned on and that your Bluetooth connection is configured."
  notice "You may need to change the value of the $DEV variable in #{__FILE__} to point to the correct tty device."
  exit 1
end

puts

notice <<NOTE
Please make sure that all four sensors are plugged in to the standard ports as follows:
Sensor 1: Touch
Sensor 2: Sound
Sensor 3: Light
Sensor 4: Ultrasonic
NOTE
prompt "Press Enter on your keyboard when ready..."

### touch sensor ######

def test_touch_sensor
  t = Commands::TouchSensor.new($nxt)
  
  info "Initializing touch sensor..."
  t = Commands::TouchSensor.new($nxt)
  
  notice "Make sure the touch sensor is NOT pressed..."
  sleep(2)
  
  t.trigger_point = :pressed
  while t.logic
  end
  
  pass "Touch sensor not pressed!"
  
  sleep(2)
  notice "Now press the touch sensor..."
  
  t.trigger_point = :released
  while t.logic
  end
  
  pass "Touch sensor pressed!"
  pass "All touch sensor tests passed!"
  t.off
  puts
end

### sound sensor ######

def test_sound_sensor
  sleep(1)
  info "Initializing sound sensor..."
  s = Commands::SoundSensor.new($nxt)
  
  sleep(1)
  notice "Now, be very quiet..."
  sleep(2)
  
  s.comparison = ">"
  s.trigger_point = 3
  while s.logic
    meter(s.sound_level, "Sound Level", 3)
  end
  
  puts
  pass "OK, sound level was below 3%"
  
  sleep(1)
  notice "Now make some noise!"
  
  s.comparison = "<"
  s.trigger_point = 75
  while s.logic
    meter(s.sound_level, "Sound Level", 75)
  end
  
  puts
  pass "OK, sound level was above 75%"
  pass "All sound sensor tests passed!"
  s.off
  puts
end

### light sensor ######

def test_light_sensor
  sleep(1)
  info "Initializing light sensor..."
  l = Commands::LightSensor.new($nxt)
  l.illuminated_mode
  
  sleep(1)
  notice "Put the light sensor up to something white or light coloured..."
  sleep(1)
  
  l.comparison = "<"
  l.trigger_point = 50
  while l.logic
    meter(l.intensity, "Colour", 50)
  end
  
  puts
  pass "OK, colour lightness was above 50%"
  
  sleep(1)
  notice "Now, put the light sensor up to something black or dark coloured..."
  sleep(2)
  
  l.comparison = ">"
  l.trigger_point = 20
  while l.logic
    meter(l.intensity, "Colour", 20)
  end
  
  puts
  pass "OK, colour lightness was below 20%"
  
  sleep(1)
  info "Switching to ambient light mode..."
  l.ambient_mode
  sleep(1)
  
  notice "Now put the light sensor under a lamp or some other bright light source..."
  sleep(2)
  
  l.comparison = "<"
  l.trigger_point = 65
  while l.logic
    meter(l.intensity, "Light", 65)
  end
  
  puts
  pass "OK, ambient light level was above 65%"
  
  sleep(1)
  notice "Now cover the light sensor with something to block out the light..."
  sleep(2)
  
  l.comparison = ">"
  l.trigger_point = 15
  while l.logic
    meter(l.intensity, "Light", 15)
  end
  
  puts
  pass "OK, ambient light level was below 15%"
  pass "All light sensor tests passed!"
  puts
  l.off
end

### ultrasonic sensor ######

def test_ultrasonic_sensor
  sleep(1)
  info "Initializing ultrasonic sensor..."
  us = Commands::UltrasonicSensor.new($nxt)
  us.mode = :centimeters
  
  sleep(1)
  notice "Point the ultrasonic sensor into the far distance -- at least 2.5 meters (7 feet)..."
  sleep(2)
  
  us.comparison = "<"
  us.trigger_point = 255
  
  while us.logic
    begin
      meter(us.distance!, "Distance (cm)", nil, 150, 0)
    rescue Commands::UltrasonicSensor::UnmeasurableDistance
      meter(nil, "Distance (cm)", nil, 150, 0)
    end
  end
  puts
  pass "OK, the sensor says it can't determine the distance (it can't pick up anything over 2 meters away or anything very very close)."
  
  sleep(1)
  notice "Now point the ultrasonic sensor at something less than 8 cm (3 inches) away..."
  sleep(1)
  
  us.comparison = ">"
  us.trigger_point = 8
  while us.logic
    begin
      meter(us.distance!, "Distance (cm)", 8, 150, 0)
    rescue Commands::UltrasonicSensor::UnmeasurableDistance
      meter(nil, "Distance (cm)", 8, 150, 0)
    end
  end
  
  puts
  pass "OK, the sensor detected an object 8 cm or less away."
  
  sleep(1)
  notice "Point the ultrasonic sensor at a wall or some other solid object 1 meter (3 feet) or further away..."
  sleep(1)
  
  us.comparison = "<"
  us.trigger_point = 100
  while us.logic
    begin
      meter(us.distance!, "Distance (cm)", 100, 150, 0)
    rescue Commands::UltrasonicSensor::UnmeasurableDistance
      meter(nil, "Distance (cm)", 100, 150, 0)
    end
  end
  
  puts
  pass "OK, the sensor detected an object over 1 meter away."
  pass "All ultrasonic sensor tests passed!"
  
  puts
end

test_touch_sensor
test_sound_sensor
test_light_sensor
test_ultrasonic_sensor

pass "CONGRATULATIONS! ruby-nxt was successfully able to communicate with all of your NXT's sensors."

$nxt.close