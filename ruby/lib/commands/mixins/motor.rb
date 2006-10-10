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

# Common methods used in motor commands.
module Commands
  module Mixins
    module Motor
      # Sets the duration of the motor movement.
      # The parameter should be a Hash like one of the following:
      #   m.duration = {:seconds => 4 }
      #   m.duration = {:degrees => 180 }
      #   m.duration = {:rotations => 2 }
      # To set the duration to unlimited (i.e. rotate indefinitely) you should set 
      # the duration to :unlimited, although this is equivalent to simply setting it to nil;
      # the following expressions are equivalent:
      #   m.duration = nil
      #   m.duration = :unlimited
      # If you assign an integer, it will be assumed that you are specifying seconds;
      # the following are equivalent:
      #   m.duration = 4
      #   m.duration = {:seconds => 4}
      # If you assign a float, it will be assumed that youa re specifying rotations;
      # the following expressions are equivalent:
      #   m.duration = 2.0
      #   m.duration = {:rotations => 2}
      def duration=(duration)
        if duration.kind_of? Hash
          @duration = duration
        elsif duration.kind_of? Integer
          @duration = {:seconds => duration}
        elsif duration.kind_of? Float
          @duration = {:rotations => duration}
        elsif duration == :unlimited
          @duration = nil
        else
          @duration = duration
        end
      end
      
      def duration
        if duration.nil?
          :unlimited
        else
          @duration
        end
      end

      protected
      def tacho_limit
        if @duration.kind_of? Hash
          if @duration[:rotations]
            tacho_limit = @duration[:rotations] * 360
          end
        
          if @duration[:degrees]
            tacho_limit = @duration[:degrees]
          end
        
          if @duration[:seconds]
            tacho_limit = 0
          end
        else
          tacho_limit = 0
        end

        tacho_limit
      end
    end
  end
end
