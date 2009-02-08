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


# This script attempts to automatically set the global $DEV variable
# by searching for a NXT tty device node.

# TODO: This curently only works on *nix based systems (MacOS X too!)
#       I don't know how to implement this for Win32 :(

# If there is an NXT or DEV environment variable, or a $DEV global,
# we'll use that and not try to auto-set it ourselves.
$DEV = $DEV || ENV['NXT'] || ENV['DEV']

unless $DEV or ENV['NXT'] or ENV['DEV']
	begin
		devices = Dir["/dev/*NXT*"]
		$DEV = devices[0] if devices.size > 0
		devices = Dir["/dev/rfcomm*"]
		$DEV = devices[0] if devices.size > 0
		puts "Auto-detected NXT at #{$DEV}"
	rescue
		$stderr.puts "WARNING: NXT could not be automatically detected!"
		# the /dev directory probably doesn't exist... maybe we're on Win32?
	end
end
