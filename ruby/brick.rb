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

require 'nxt_comm'

# Abstract parent class of motor and sensor bricks.
# Currently provides only very basic common functionality but may
# be expanded in the future.
class Brick

	def initialize(port, dev = $DEV)
		logfile = File.expand_path(File.dirname(__FILE__))+"/#{self.class}_#{port}.log"
		@log = Logger.new logfile
		@log.level = Logger::DEBUG
		#puts "Logging to #{logfile}"

		debug("#{self.class}::#{dev}(#{port})", :initialize)
		
		@nxt = NXTComm.connect(dev)
		@nxt.start
	end

	private
		def debug(msg, method = false)
			@log.info(method) do 
				if msg.kind_of? String
					msg
				else
					msg.to_yaml
				end
			end
		end

end