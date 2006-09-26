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

# Implements the "Light Sensor" block in NXT-G
class Commands::LightSensor

  attr_reader :port, :generate_light
  attr_accessor :trigger_point, :comparison
  
  def initialize(nxt)
    @nxt      = nxt
    
    # defaults the same as NXT-G
    @port           = 3
    @trigger_point  = 50
    @comparison     = ">"
    @generate_light = true
    set_mode
  end

  def port=(port)
    @port = port
    set_mode
  end

  # Determines if the sensor's own LED is on or not (true or false)
  def generate_light=(logic)
    @generate_light = logic
    set_mode
  end

  # returns true or false based on comparison and trigger point
  def logic
    case @comparison
      when ">"
        intensity >= @trigger_point ? true : false
      when "<"
        intensity <= @trigger_point ? true : false
    end
  end
  
  # intensity of light detected 0-100 in %
  def intensity
    value_scaled
  end
  
  # returns the raw value of the sensor
  def raw_value
    value_raw
  end
  
  # sets up the sensor port
  def set_mode
    @generate_light ? mode = NXTComm::LIGHT_ACTIVE : mode = NXTComm::LIGHT_INACTIVE
    @nxt.set_input_mode(
      NXTComm.const_get("SENSOR_#{@port}"),
      mode,
      NXTComm::PCTFULLSCALEMODE
    )
  end
  
  # attempt to return the input_value requested
  def method_missing(cmd)
    @nxt.get_input_values(NXTComm.const_get("SENSOR_#{@port}"))[cmd]
  end
end
