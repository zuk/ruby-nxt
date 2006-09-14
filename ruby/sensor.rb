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

require File.dirname(__FILE__)+'/brick'

# Controls and reads an NXT sensor.
class Sensor < Brick

	POLL_INTERVAL = 0.5
	
	# TODO: internal sensor numbering is 0x00 to 0x03, but sensor ports on the brick are marked 1 to 4...
	# 			need to come up with some way to make sure there isn't confusion (or maybe it's okay, since
	# 			if the user probably never uses the Sensor classes directly, only interacting via the NXT
	# 			class?)
	
	
	def initialize(nxt, port)
		super(nxt, port)
		@port = port
	end
	
	
	def name
		"#{@port + 1}"
	end

	def set_input_mode(type, mode)
		@nxt.SetInputMode(@port, type, mode)
	end
	
	def read_data
		raw = @nxt.GetInputValues(@port)
		
		data = {
				:port => raw[0],
				:valid? => raw[1],
				:calibrated? => raw[2],
				:type => raw[3],
				:mode => raw[4],
				:raw_value => raw[5],
				:normalized_value => raw[6],
				:scaled_value => raw[7],
				:calibrated_value => raw[8]
			}
		
		debug(data.inspect, :read_data)
		return data
	end
	
	def disconnect
		# Turns off the sensor before disconnecting (for example we turn off
		# the red light on the light sensor this way).
		set_input_mode(NXTComm::NO_SENSOR, NXTComm::RAWMODE)
		super
	end
	
end