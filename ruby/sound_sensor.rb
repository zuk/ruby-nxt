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

class SoundSensor < Sensor
	
	def initialize(port, dev = $DEV)
		super(port, dev)
		set_input_mode(NXTComm::SOUND_DB, NXTComm::RAWMODE)
	end
	
	# Get the current sound level as a float from 0 to 1.0.
	# 1.0 is maximum, 0 is minimum.
	def get_sound_level
		# TODO: should probably do some basic calibration here... it never really seems to get to 1023
		(read_data[:scaled_value]).to_f / 1023.to_f
	end
	
end