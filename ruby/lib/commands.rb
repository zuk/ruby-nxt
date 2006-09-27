# Command object based interface that implements the "blocks" in NXT-G.  This should
# be easy to understand if you are familiar with the NXT-G graphical programming
# system.  This is automatically included in NXTComm.
#
# === Example
#
#   require 'nxt_comm'
# 
#   @nxt = NXTComm.new('/dev/tty.NXT-DevB-1')
#
#   # more examples can be found in examples/commands.rb
#
#   us = Commands::UltrasonicSensor.new(@nxt)
#   us.mode = :centimeters
#   puts "Distance: #{us.distance}cm"
#   us.mode = :inches
#   puts "Distance: #{us.distance}in"
# 
#   us.comparison = "<"
#   us.trigger_point = 5
# 
#   while us.logic == false
#     sleep(0.5)
#     puts "Move #{us.comparison} #{us.trigger_point} #{us.mode} from the sensor..."
#     puts "Distance: #{us.distance}in"
#   end
# 
#   puts "Got it!"
#
module Commands

  require File.dirname(File.expand_path(__FILE__))+'/commands/move'
  require File.dirname(File.expand_path(__FILE__))+'/commands/sound'
  require File.dirname(File.expand_path(__FILE__))+'/commands/motor'

  require File.dirname(File.expand_path(__FILE__))+'/commands/touch_sensor'
  require File.dirname(File.expand_path(__FILE__))+'/commands/sound_sensor'
  require File.dirname(File.expand_path(__FILE__))+'/commands/light_sensor'
  require File.dirname(File.expand_path(__FILE__))+'/commands/ultrasonic_sensor'
  require File.dirname(File.expand_path(__FILE__))+'/commands/rotation_sensor'

end