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

# Implements the "TouchSensor" block in NXT-G
class TouchSensor

  attr_reader :port, :action
  
  def initialize(nxt)
    @nxt      = nxt
    
    # defaults the same as NXT-G
    @port   = 1
    @action = :pressed
    set_mode
  end

  def port=(port)
    @port = port
    set_mode
  end

  def action=(action)
    @action = action
    set_mode
  end

  # returns true or false based on action type
  def state
    state = @nxt.get_input_values(NXTComm.const_get("SENSOR_#{@port}"))
    case @action
      when :pressed
        state[:value_scaled] > 0 ? true : false
      when :released
        state[:value_scaled] > 0 ? false : true
      when :bumped
        # TODO figure out bumped mode...
        raise "Not Implemented Yet"
    end
  end
  
  def reset
    @nxt.reset_input_scaled_value(NXTComm.const_get("SENSOR_#{@port}"))
  end
  
  def set_mode
    @nxt.set_input_mode(
      NXTComm.const_get("SENSOR_#{@port}"),
      NXTComm::SWITCH,
      NXTComm::BOOLEANMODE
    )
  end
end
