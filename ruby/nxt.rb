# ruby-nxt Control Mindstorms NXT via Bluetooth Serial Port Connection
# Copyright (C) 2006 Matt Zukowski <matt@roughest.net>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

require File.dirname(__FILE__)+'/nxt_comm'
require File.dirname(__FILE__)+'/motor'

# High-level interface for controlling motors and sensors connected to the NXT.
# Currently only motors and some other misc functionality is implemented.
# 
# Examples:
# 
#   nxt = NXT.new('/dev/tty.NXT-DevB-1')
#   
#   nxt.motor_a do |m|
#   	m.forward(:degrees => 180, :power => 15)
#   end
#   
#   nxt.motors_bc do |m|
#     m.backward(:time => 5, :power => 20)
#   end
#   
#   nxt.motors_abc do |m|
#   	m.reset_tacho
#   	m.forward(:time => 3, :power => 10)
#   	puts "Motor #{m.name} moved #{m.read_state[:degree_count]} degrees."
#   end
#   
#   nxt.disconnect
# 
# Be sure to call NXT#disconnect when done sending commands, otherwise there may be trouble
# if you try to connect or send commands again afterwards.
# 
class NXT

	# Initialize the NXT. This creates three Motor instances and one kind of each sensor.
	# It is assumed that the sensors are connected to the standard ports as follows:
	# * Port 1: Touch
	# * Port 2: Sound
	# * Port 3: Light
	# * Port 4: Ultrasonic
	# You can specify the path to the serialport device (e.g. '/dev/tty.NXT-DevB-1')
	# or omit the argument to use the serialport device specified in the global
	# $DEV variable.
	def initialize(dev = $DEV)
		@nxt = NXTComm.new(dev)
		
		@motors = {}
		@motors[:a] = Motor.new(@nxt, :a)
		@motors[:b] = Motor.new(@nxt, :b)
		@motors[:c] = Motor.new(@nxt, :c)
		
		@motor_threads = {}
	end
	
	def method_missing(method, *args, &block)
		name = method.id2name
		if /^motor_([abc])$/ =~ name
			motor($1, block)
		elsif /^motors_([abc]+?)$/ =~ name
			motors($1, block)
		else
			raise "Unknown method '#{method}'"
		end
	end
	
	# Runs the given proc for multiple motors.
	# You should use the motors_xxx dynamic method instead of calling this directly.
	# For example...
	# 
	#   nxt.motors_abc {|m| m.forward(:degrees => 180)}
	# 
	# ...would run the given block simultanously on all three motors,
	# while...
	# 
	#   nxt.motors_bc {|m| m.forward(:degrees => 180)}
	#  
	# ...would only run it on motors B and C.
	def motors(which, proc)
		which = which.scan(/\w/) if which.kind_of? String
		which = which.uniq
		which = @motors.keys if which.nil? or which.empty?
		
		which.each do |id|
			motor(id, proc)
		end
	end
	
	# Runs the given proc for the given motor.
	# You should use the motor_x dynamic method instead of calling this directly.
	# For example...
	# 
	#   nxt.motor_a {|m| m.forward(:degrees => 180)}
	# 
	# ...would rotate motor A by 180 degrees,
	# while...
	# 
	#   nxt.motor_b {|m| m.forward(:degrees => 180)}
	# 
	# ...would do the same for motor B.
	def motor(id, proc)
		id = id.intern if id.kind_of? String
		
		@motor_threads[id].join if (@motor_threads[id] and @motor_threads[id].alive?)
		
		t = Thread.new(@motors[id]) do |m|
			proc.call(m)
		end
		
		@motor_threads[id] = t
	end
	
	# Waits for all running jobs to finish and cleanly closes
	# all connections to the NXT device.
	# You should _always_ call this when done sending commands
	# to the NXT.
	def disconnect
		@motor_threads.each {|i,t| t.join}
		@nxt.close
	end

end