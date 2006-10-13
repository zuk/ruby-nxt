# ruby-nxt Control Mindstorms NXT via Bluetooth Serial Port Connection
# Copyright (C) 2006 Tony Buser <tbuser@gmail.com> - http://juju.org
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

require "nxt_comm"
require "ultrasonic_comm"
require "commands/mixins/sensor"

# Implements the "Ultrasonic Sensor" block in NXT-G
class Commands::UltrasonicSensor
  
  include Commands::Mixins::Sensor
  
  # Exception thrown by distance! when the sensor cannot determine the distance.
  class UnmeasurableDistance < Exception; end
  
  attr_reader :port
  attr_accessor :mode, :trigger_point, :comparison
  
  def initialize(nxt)
    @nxt      = nxt
    
    # defaults the same as NXT-G
    @port           = 4
    @trigger_point  = 50
    @comparison     = "<"
    @mode           = :inches
    set_mode
  end
  
  # returns distance in requested mode (:inches or :centimeters)
  def distance
    @nxt.ls_write(NXTComm.const_get("SENSOR_#{@port}"), UltrasonicComm.read_measurement_byte(0))
    
    # Keep checking until we have data to read
    while @nxt.ls_get_status(NXTComm.const_get("SENSOR_#{@port}")) < 1
      sleep(0.1)
      # TODO: implement timeout so we don't get stuck if the expected data never comes
    end
    
    distance = @nxt.ls_read(NXTComm.const_get("SENSOR_#{@port}"))[:data][0]
    
    if @mode == :centimeters
      distance.to_i
    else
     (distance * 0.3937008).to_i
    end
  end
  alias value_scaled distance
  
  # returns the distance in requested mode; raises an UnmeasurableDistance exception
  # when the distance cannot be measured (i.e. when the distance == 255, which is
  # the code the sensor returns when it cannot get a distance reading)
  def distance!
    d = distance
    raise UnmeasurableDistance if d == 255
    return d
  end
  
  # sets up the sensor port
  def set_mode
    @nxt.set_input_mode(
      NXTComm.const_get("SENSOR_#{@port}"),
      NXTComm::LOWSPEED_9V,
      NXTComm::RAWMODE
    )
    # clear buffer
    @nxt.ls_read(NXTComm.const_get("SENSOR_#{@port}"))
    # set sensor to continuously send pings
    @nxt.ls_write(NXTComm.const_get("SENSOR_#{@port}"), UltrasonicComm.continuous_measurement_command)
  end
end
