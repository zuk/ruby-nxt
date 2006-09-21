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

require 'yaml'

require File.dirname(File.expand_path(__FILE__))+'/sensor'

class LightSensor < Sensor
  
  def initialize(nxt, port = NXTComm::SENSOR_3)
    super(nxt, port)
    use_illuminated_mode
  end
  
  # Get the current light level as a float from 0 to 1.0.
  # 1.0 is maximum, 0 is minimum.
  def get_light_level
    # TODO: probably need to calibrate this... light level never really reaches 1023
    (read_data[:value_scaled]).to_f / 1023.to_f
  end
  

  def use_illuminated_mode
    set_input_mode(NXTComm::LIGHT_ACTIVE, NXTComm::RAWMODE)
  end
  

  def use_ambient_mode
    set_input_mode(NXTComm::LIGHT_INACTIVE, NXTComm::RAWMODE)
  end
  
end