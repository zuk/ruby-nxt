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

require File.dirname(__FILE__)+'/../brick'

# Controls and reads an NXT sensor.
class Sensor < Brick

  POLL_INTERVAL = 0.25
  
  # TODO: internal sensor numbering is 0x00 to 0x03, but sensor ports on the brick are marked 1 to 4...
  #       need to come up with some way to make sure there isn't confusion (or maybe it's okay, since
  #       if the user probably never uses the Sensor classes directly, only interacting via the NXT
  #       class?)
  
  
  def initialize(nxt, port)
    super(nxt, port)
    @port = port
  end
  
  def name
    "#{@port + 1}"
  end

  def set_input_mode(type, mode)
    @nxt.set_input_mode(@port, type, mode)
  end
  
  def read_data
    data = @nxt.get_input_values(@port)
    
    debug(data.inspect, :read_data)
    return data
  end
  
  # Continuously evalutes the given block until it returns at
  # least the given value (that is, until the block returns a
  # value equal or greater than the given argument). If no
  # value is specified, the block will be continuously
  # evaluated until it returns true. Optionally, a comparison
  # operator can be specified as the second parameter,
  # otherwise >= is used (or == if expected value is Boolean).
  # 
  # Simple example:
  # 
  #   ts = TouchSensor.new(@nxt)
  #   ts.wait_for_event { ts.is_pressed? }
  #   
  # Example with an expected value:
  # 
  #   ls = LightSensor.new(@nxt)
  #   ls.wait_for_event(0.55) do
  #   	ls.get_light_level
  #   end
  #
  def wait_for_event(expected = true, operator = nil)
  	if operator
  		comp = operator
  	elsif expected.respond_to? '>='.intern
  		comp = ">="
  	else
  		comp = "=="
  	end
  	
  	while true
  		value = yield
  		return value if eval("value #{comp} expected")
  		sleep(POLL_INTERVAL)
  	end
  end
  
  def off
    # Turns off the sensor.
    set_input_mode(NXTComm::NO_SENSOR, NXTComm::RAWMODE)
  end
  
end