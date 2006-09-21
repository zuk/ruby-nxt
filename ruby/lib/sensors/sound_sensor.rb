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

class SoundSensor < Sensor
  
  def initialize(nxt, port = NXTComm::SENSOR_2)
    super(nxt, port)
    use_adjusted_mode
  end
  
  # Get the current sound level as a float from 0 to 1.0.
  # 1.0 is maximum, 0 is minimum.
  def get_sound_level
    # TODO: should probably do some basic calibration here...
    read_data[:value_normal] / 1023.to_f
  end
  
  # Sound level measurement is NOT adjusted to match the psychoacoustic properties
  # of human hearing. Sounds that may not be loud to the human ear may show up as loud
  # and vice versa.
  def use_unadjusted_mode
    set_input_mode(NXTComm::SOUND_DB, NXTComm::RAWMODE)
  end
  
  # Sound level measurement is adjusted to match the psychoacoustic properties of
  # human hearing. This is on by default.
  def use_adjusted_mode
    set_input_mode(NXTComm::SOUND_DBA, NXTComm::RAWMODE)
  end
  
end