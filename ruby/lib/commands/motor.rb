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

# Implements the "Motor" block in NXT-G
class Commands::Motor
  
  attr_accessor :port
  attr_accessor :direction
  attr_accessor :steering
  attr_accessor :action
  attr_accessor :power
  attr_accessor :control_power
  attr_accessor :duration
  attr_accessor :wait
  attr_accessor :next_action
  
  def initialize(nxt = nil)
    @nxt          = nxt || NXTComm.new($DEV)
    
    # defaults the same as NXT-G
    @port           = :a
    @direction      = :forward
    @action         = :constant
    @power          = 75
    @control_power  = false
    @duration       = nil # Same as :unlimited
    @wait           = false
    @next_action    = :brake
  end
  
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

  # execute the Motor command based on the properties specified
  def start
    @nxt.reset_motor_position(NXTComm.const_get("MOTOR_#{@port.to_s.upcase}"))

    if @direction == :stop
      motor_power = 0
      mode        = NXTComm::COAST
      run_state   = NXTComm::MOTOR_RUN_STATE_IDLE
    else
      @direction == :forward ? motor_power = @power : motor_power = -@power
      mode        = NXTComm::MOTORON | NXTComm::BRAKE
      run_state   = NXTComm::MOTOR_RUN_STATE_RUNNING
    end

    turn_ratio = 0

    if @control_power
      mode |= NXTComm::REGULATED
      reg_mode = NXTComm::REGULATION_MODE_MOTOR_SPEED
    else
      reg_mode = NXTComm::REGULATION_MODE_IDLE
    end
    
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

    if @duration
      if @duration[:degrees] or @duration[:seconds]
        case @action
          when :constant
            run_state = NXTComm::MOTOR_RUN_STATE_RUNNING
          when :ramp_up
            run_state = NXTComm::MOTOR_RUN_STATE_RAMPUP
          when :ramp_down
            run_state = NXTComm::MOTOR_RUN_STATE_RAMPDOWN
        end
      end
    end

    @nxt.set_output_state(
      NXTComm.const_get("MOTOR_#{@port.to_s.upcase}"),
      motor_power,
      mode,
      reg_mode,
      turn_ratio,
      run_state,
      tacho_limit
    )
    
    if (@duration and @duration[:seconds]) or @wait
      if @duration and @duration[:seconds]
        sleep(@duration[:seconds])
      else
        until self.run_state == NXTComm::MOTOR_RUN_STATE_IDLE
          sleep(0.25)
        end
      end
      self.stop
    end
  end
  
  # stop the Motor command based on the next_action property
  def stop
    if @next_action == :brake
      @nxt.set_output_state(
        NXTComm.const_get("MOTOR_#{@port.to_s.upcase}"),
        0,
        NXTComm::MOTORON | NXTComm::BRAKE | NXTComm::REGULATED,
        NXTComm::REGULATION_MODE_MOTOR_SPEED,
        0,
        NXTComm::MOTOR_RUN_STATE_RUNNING,
        0
      )
    else
      @nxt.set_output_state(
        NXTComm.const_get("MOTOR_#{@port.to_s.upcase}"),
        0,
        NXTComm::COAST,
        NXTComm::REGULATION_MODE_IDLE,
        0,
        NXTComm::MOTOR_RUN_STATE_IDLE,
        0
      )
    end
  end
  
  # attempt to return the output_state requested
  def method_missing(cmd)
    @nxt.get_output_state(NXTComm.const_get("MOTOR_#{@port.to_s.upcase}"))[cmd]
  end
  
end