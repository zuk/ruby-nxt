# ruby-nxt Control Mindstorms NXT via Bluetooth Serial Port Connection
# Copyright (c) 2006 Tony Buser <tbuser@gmail.com> - http://juju.org
# Copyright (c) 2006 Matt Zukowski <matt@roughest.net> - http://blog.roughest.net
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

# Common methods used in sensor commands.
module Commands
  module Mixins
    module Sensor
      def port=(port)
        @port = port
        set_mode
      end
      
      def comparison=(op)
        raise ArgumentError, "'#{op}' is not a valid comparison operator." unless op =~ /^([<>=]=?|!=)$/
        @comparison = op
      end
      
      # Returns true or false based on comparison and trigger point.
      def logic
        eval "value_scaled #{@comparison} @trigger_point"
      end
    end
  end
end
