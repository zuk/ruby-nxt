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
# 
require File.dirname(File.expand_path(__FILE__))+'/sensor'
require File.dirname(File.expand_path(__FILE__))+'/ultrasonic_comm'

class UltrasonicSensor < Sensor
  
  INCHES_PER_CM = 0.3937008
  
  def initialize(nxt, port = NXTComm::SENSOR_4)
    super(nxt, port)
    
    # The Ultrasonic sensor is digital and unlike the other sensors it
    # uses the lowspeed communication protocol.
    set_input_mode(NXTComm::LOWSPEED_9V, NXTComm::RAWMODE)
    
    # Read the sensor in case there was some garbage data in the buffer waiting to be read
    @nxt.ls_read(@port)
    
    # Set the sensor to continuously send pings
    @nxt.ls_write(@port, UltrasonicComm.continuous_measurement_command)
  end
  
  # Return the measured distance in the default units (the default units being centimeters).
  # A value of 255 is returned when the sensor cannot get an accurate reading (because
  # the object is out of range, or there is too much interference, etc.)
  # Note that the sensor's real-world range is at best 175 cm. At larger distances it
  # will almost certainly just return 255.
  def get_distance
    @nxt.ls_write(@port, UltrasonicComm.read_measurement_byte(0))
    
    # Keep checking until we have 1 byte of data to read
    while @nxt.ls_get_status(@port)[0] < 1
      sleep(0.1)
      @nxt.ls_write(@port, UltrasonicComm.read_measurement_byte(0))
      # TODO: implement timeout so we don't get stuck if the expected data never comes
    end
    
    resp = @nxt.ls_read(@port)
    # TODO: probably need a better error message here...
  	raise "ls_read returned more than one byte!" if resp[:bytes_read] > 1
  	raise "ls_read did not return any data!" if resp[:bytes_read] < 1
 
 		# If the sensor cannot determine the distance, it will return
 		# 0xff (255)... this usually means that the object is out of
 		# sensor range, but it can also mean that there is too much
 		# interference or that the object is too close to the sensor.
 		# I considered returning nil or false under such cases, but
 		# this makes numeric comparison (i.e. greather than/less than)
 		# more difficult
 		d = resp[:data][0]
  end
  alias_method :get_distance_in_cm, :get_distance
  
  # Return the measured distance in inches.
  def get_distance_in_inches   	
    get_distance.to_f * INCHES_PER_CM
  end

	# Same as get_distance, but raises an UnmeasurableDistance
	# exception when the sensor cannot accurately determine
	# the distance.
	def get_distance!
		d = get_distance
		if d == 255
			raise UnmeasurableDistance
		else
			return d
		end
  end
  alias_method :get_distance_in_cm!, :get_distance!
  
  def get_distance_in_inches!
  	get_distance!.to_f * INCHES_PER_CM
  end
  
  # Exception thrown by get_distance! and related methods when
  # the sensor cannot determine the distance.
  class UnmeasurableDistance < Exception; end
  
end