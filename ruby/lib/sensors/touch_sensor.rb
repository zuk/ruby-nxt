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

require File.dirname(__FILE__)+'/sensor'

class TouchSensor < Sensor
  
  def initialize(nxt, port = NXTComm::SENSOR_1)
    super(nxt, port)
    set_input_mode(NXTComm::SWITCH, NXTComm::BOOLEANMODE)
  end
  
  # Returns true if the touch sensor is pressed, false otherwise.
  # (The sensor seems to read as "pressed" when it is pushed in about half way)
  def is_pressed?
    read_data[:value_scaled] > 0
  end
  alias_method :pressed?, :is_pressed?
  
end