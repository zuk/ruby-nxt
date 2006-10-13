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

require "nxt_comm"
require "commands/mixins/motor"

# Implements the "Motor" block in NXT-G
class Commands::Motor
  
  include Commands::Mixins::Motor 

  attr_accessor :port
  attr_accessor :direction
  attr_accessor :steering
  attr_accessor :action
  attr_accessor :power
  attr_accessor :control_power
  attr_accessor :wait
  attr_accessor :next_action
  
  def initialize(nxt = NXTComm.new($DEV))
    @nxt          = nxt
    
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
