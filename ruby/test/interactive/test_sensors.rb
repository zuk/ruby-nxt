require File.dirname(__FILE__)+'/../../touch_sensor'
require File.dirname(__FILE__)+'/../../light_sensor'
require File.dirname(__FILE__)+'/../../sound_sensor'

require File.dirname(__FILE__)+'/interactive_test_helper.rb'

include InteractiveTestHelper

$DEV = '/dev/tty.NXT-DevB-1'

info "Connecting to NXT..."

nxt = NXTComm.new($DEV)

### touch sensor ######

info "Initializing touch sensor..."
t = TouchSensor.new(nxt)
notice "Make sure the touch sensor is NOT pressed..."
t.wait_for_event { not t.pressed? }
pass "Touch sensor not pressed!"

notice "Now press the touch sensor..."
t.wait_for_event { t.pressed? }
pass "Touch sensor pressed!"
pass "All touch sensor tests passed!"
t.off

### sound sensor ######

info "Initializing sound sensor..."
s = SoundSensor.new(nxt)
notice "Now, be very quiet..."
s.wait_for_event(0.2, "<") do
	meter(s.get_sound_level, "Sound Level", 0.2)
	s.get_sound_level
end
puts
pass "OK, sound level was below 20%"

notice "Now make some noise!"
s.wait_for_event(0.8) do
	meter(s.get_sound_level, "Sound Level", 0.8)
	s.get_sound_level
end
puts
pass "OK, sound level was above 80%"
pass "All sound sensor tests passed!"
s.off

### light sensor ######

info "Initializing light sensor..."
l = LightSensor.new(nxt)

notice "Put the light sensor up to something white or light coloured..."
l.wait_for_event(0.6) do
	meter(l.get_light_level, "Colour", 0.55)
	l.get_light_level
end
puts
pass "OK, colour lightness was above 70%"

notice "Now, put the light sensor up to something black or dark coloured..."
l.wait_for_event(0.25, "<") do
	meter(l.get_light_level, "Colour", 0.25)
	l.get_light_level
end
puts
pass "OK, colour lightness was below 30%"

info "Switching to ambient light mode..."
l.use_ambient_mode

notice "Now put the light sensor under a lamp or some other bright light source..."
l.wait_for_event(0.7) do
	meter(l.get_light_level, "Light", 0.7)
	l.get_light_level
end
puts
pass "OK, light level was above 70%"

notice "Now cover the light sensor with something to block out the light..."
l.wait_for_event(0.2, "<") do
	meter(l.get_light_level, "Light", 0.2)
	l.get_light_level
end
puts
pass "OK, light level was below 20%"
pass "All light sensor tests passed!"

l.off

nxt.close