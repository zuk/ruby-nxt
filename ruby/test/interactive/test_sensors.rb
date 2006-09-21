require File.dirname(File.expand_path(__FILE__))+'/../../lib/sensors/touch_sensor'
require File.dirname(File.expand_path(__FILE__))+'/../../lib/sensors/light_sensor'
require File.dirname(File.expand_path(__FILE__))+'/../../lib/sensors/sound_sensor'
require File.dirname(File.expand_path(__FILE__))+'/../../lib/sensors/ultrasonic_sensor'

require File.dirname(File.expand_path(__FILE__))+'/interactive_test_helper.rb'

include InteractiveTestHelper

require File.dirname(File.expand_path(__FILE__))+'/../../lib/autodetect_nxt'

info "Connecting to the NXT at #{$DEV}..."

begin
	nxt = NXTComm.new($DEV)
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

info "Initializing touch sensor..."
t = TouchSensor.new(nxt)
notice "Make sure the touch sensor is NOT pressed..."
sleep(3)
t.wait_for_event { not t.pressed? }
pass "Touch sensor not pressed!"

sleep(2)
notice "Now press the touch sensor..."
t.wait_for_event { t.pressed? }
pass "Touch sensor pressed!"
pass "All touch sensor tests passed!"
t.off
puts

### sound sensor ######

sleep(1)
info "Initializing sound sensor..."
s = SoundSensor.new(nxt)

sleep(1)
notice "Now, be very quiet..."
sleep(2)
s.wait_for_event(0.025, "<") do
	meter(s.get_sound_level, "Sound Level", 0.025)
	s.get_sound_level
end
puts
pass "OK, sound level was below 2.5%"

sleep(1)
notice "Now make some noise!"
s.wait_for_event(0.75) do
	meter(s.get_sound_level, "Sound Level", 0.75)
	s.get_sound_level
end
puts
pass "OK, sound level was above 75%"
pass "All sound sensor tests passed!"
s.off
puts

### light sensor ######

sleep(1)
info "Initializing light sensor..."
l = LightSensor.new(nxt)

sleep(1)
notice "Put the light sensor up to something white or light coloured..."
sleep(1)
l.wait_for_event(0.5) do
	meter(l.get_light_level, "Colour", 0.5)
	l.get_light_level
end
puts
pass "OK, colour lightness was above 50%"

sleep(1)
notice "Now, put the light sensor up to something black or dark coloured..."
sleep(2)
l.wait_for_event(0.2, "<") do
	meter(l.get_light_level, "Colour", 0.2)
	l.get_light_level
end
puts
pass "OK, colour lightness was below 20%"

sleep(1)
info "Switching to ambient light mode..."
l.use_ambient_mode
sleep(1)

notice "Now put the light sensor under a lamp or some other bright light source..."
sleep(2)
l.wait_for_event(0.65) do
	meter(l.get_light_level, "Light", 0.65)
	l.get_light_level
end
puts
pass "OK, ambient light level was above 65%"

sleep(1)
notice "Now cover the light sensor with something to block out the light..."
sleep(2)
l.wait_for_event(0.15, "<") do
	meter(l.get_light_level, "Light", 0.15)
	l.get_light_level
end
puts
pass "OK, ambient light level was below 15%"
pass "All light sensor tests passed!"
puts
l.off

### ultrasonic sensor ######

sleep(1)
info "Initializing ultrasonic sensor..."
u = UltrasonicSensor.new(nxt)

sleep(1)
notice "Point the ultrasonic sensor into the far distance -- at least 2.5 meters (7 feet)..."
sleep(2)
u.wait_for_event do
	begin
		d = u.get_distance_in_cm!
		meter(d, "Distance (cm)", nil, 150, 0)
	rescue UltrasonicSensor::UnmeasurableDistance
		meter(nil, "Distance (cm)", nil, 150, 0)
		true
	end
end
puts
pass "OK, the sensor says it can't determine the distance (it can't pick up anything over 2 meters away or anything very very close)."

sleep(1)
notice "Now point the ultrasonic sensor at something less than 8 cm (3 inches) away..."
sleep(1)
u.wait_for_event(8, "<=") do
	begin
		d = u.get_distance_in_cm!
		meter(d, "Distance (cm)", 8, 150, 0)
		d
	rescue UltrasonicSensor::UnmeasurableDistance
		9999
	end
end
puts
pass "OK, the sensor detected an object 8 cm or less away."

sleep(1)
notice "Point the ultrasonic sensor at a wall or some other solid object 1 meter (3 feet) or further away..."
sleep(1)
u.wait_for_event(100, ">=") do
	begin
		d = u.get_distance_in_cm!
		meter(d, "Distance (cm)", 100, 150, 0)
		d
	rescue UltrasonicSensor::UnmeasurableDistance
		meter(nil, "Distance (cm)", 100, 150, 0)
		0
	end
end
puts
pass "OK, the sensor detected an object over 1 meter away."
pass "All ultrasonic sensor tests passed!"

u.off

puts
pass "CONGRATULATIONS! ruby-nxt was successfully able to communicate will all of your NXT's sensors."

nxt.close