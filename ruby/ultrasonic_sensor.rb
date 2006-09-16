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
require File.dirname(__FILE__)+'/sensor'
require File.dirname(__FILE__)+'/ultrasonic_comm'

class UltrasonicSensor < Sensor
  
  def initialize(nxt, port = NXTComm::SENSOR_4)
    super(nxt, port)
    
    # The Ultrasonic sensor is digital and unlike the other sensors it
    # uses the lowspeed communication protocol.
    set_input_mode(NXTComm::LOWSPEED_9V, NXTComm::RAWMODE)
    
    # Read the sensor in case there was some garbage data in the buffer waiting to be read
    @nxt.ls_read(@port)
    
    # I think the sensor uses continuous measurement by default, but it doesn't hurt to
    # send this command just in case.
    @nxt.ls_write(@port, UltrasonicComm.continuous_measurement_command)
  end
  
  # Return raw data from the ultrasonic sensor (via the I2C controller).
  def read_data
  	
  end
  
  # Return the measured distance in the default units (the default units being centimeters).
  def get_distance
    @nxt.ls_write(@port, UltrasonicComm.read_measurement_byte(0))
    
    # Keep checking until we have 1 byte of data to read
    while @nxt.ls_get_status(@port)[0] < 1
      sleep(0.1)
      @nxt.ls_write(@port, UltrasonicComm.read_measurement_byte(0))
      # TODO: implement timeout so we don't get stuck if the expected data never comes
    end
    
    resp = @nxt.ls_read(@port)
    # FIXME: probably need a better error message here...
  	raise "ls_read returned more than one byte!" if resp[:bytes_read] > 1
  	raise "ls_read did not return any data!" if resp[:bytes_read] < 1
 
 		# TODO: if the sensor cannot determine the distance, it will return
 		#       0xff (255)... this usually means that the object is out of
 		#       sensor range, but it can also mean that there is too much
 		#       interference or that the object is too close to the sensor.
 		#       Maybe we need to handle this differently, via some wrapper
 		#       class that handles the special 255 value differently?
 		d = resp[:data][0]
  end
  alias_method :get_distance_in_cm, :get_distance
  
  # Return the measured distance in inches.
  def get_distance_in_inches   	
    get_distance.to_f * 0.3937008
  end

  
end