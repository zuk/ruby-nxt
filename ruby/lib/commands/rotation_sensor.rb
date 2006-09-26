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

# Implements the "Rotation Sensor" block in NXT-G (using an nxt motor as rotation sensor)
class Commands::RotationSensor

  attr_accessor :port, :trigger_direction, :trigger_point, :comparison
  
  def initialize(nxt)
    @nxt      = nxt
    
    # defaults the same as NXT-G
    @port               = :a
    @trigger_direction  = :forward
    @trigger_point      = 360
    @comparison         = ">"
    reset
    @internal_counter   = degrees
  end

  # returns true or false based on comparison type and difference between last time reset point
  def logic
    @trigger_direction == :forward ? trigger = @trigger_point : trigger = -@trigger_point
    case @comparison
      when ">"
        degrees >= trigger ? true : false
      when "<"
        degrees <= trigger ? true : false
    end
  end
  
  # resets the value_scaled property, use this to reset the degrees counter
  def reset
    @nxt.reset_motor_position(NXTComm.const_get("MOTOR_#{@port.to_s.upcase}"))
  end
  
  # returns the number of degrees moved since last reset point
  def degrees
    @internal_counter = rotation_count
    @internal_counter
  end
  
  # attempts to determine direction based on last time position was requested (may not be accurate)
  def direction
    case true
      when rotation_count > @internal_counter
        "forwards"
      when rotation_count < @internal_counter
        "backwards"
      when rotation_count == @internal_counter
        "stopped"
    end
  end
  
  # attempt to return the output_state requested
  def method_missing(cmd)
    @nxt.get_output_state(NXTComm.const_get("MOTOR_#{@port.to_s.upcase}"))[cmd]
  end
end
