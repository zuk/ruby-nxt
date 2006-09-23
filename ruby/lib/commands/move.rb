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

# Implements the "Move" block in NXT-G
class Move
  
  attr_reader :ports
  attr_accessor :direction
  attr_accessor :steering
  attr_accessor :power
  attr_accessor :duration
  attr_accessor :next_action
  
  def initialize(nxt)
    @nxt          = nxt
    
    # defaults the same as NXT-G
    @ports        = [:b, :c]
    @direction    = :forward
    @steering     = {:left_motor => :b, :right_motor => :c, :direction => :straight, :power => 100}
    @power        = 75
    @duration     = {:rotations => 1}
    @next_action  = :brake
  end

  def ports=(value)
    # make it flexible, let them specify just :a, or "A", or :a,:b to do two etc.
    case value.class.to_s
      when "Symbol" then @ports = [value]
      when "String" then @ports = [value.intern]
      when "Array"  then @ports = value
      else raise "Invalid port type #{value.class}"
    end
  end

  # execute the Move command based on the properties specified
  def start
    @ports.each do |p|
      @nxt.reset_motor_position(NXTComm.const_get("MOTOR_#{p.to_s.upcase}"))
    end

    if @direction == :stop
      motor_power = 0
      mode        = NXTComm::COAST
      run_state   = NXTComm::MOTOR_RUN_STATE_IDLE
    else
      @direction == :forward ? motor_power = @power : motor_power = -@power
      mode        = NXTComm::MOTORON | NXTComm::BRAKE
      run_state   = NXTComm::MOTOR_RUN_STATE_RUNNING
    end

    if @ports.size == 2
      mode |= NXTComm::REGULATED
      reg_mode = NXTComm::REGULATION_MODE_MOTOR_SYNC

      case @steering[:direction]
        when :straight
          turn_ratio = 0
        when :spin_left
          turn_ratio = -100
        when :spin_right
          turn_ratio = 100
        when :left
          @steering[:power].nil? ? turn_ratio = -50 : turn_ratio = -@steering[:power]
        when :right
          @steering[:power].nil? ? turn_ratio = 50 : turn_ratio = @steering[:power]
      end
    else
      reg_mode = NXTComm::REGULATION_MODE_IDLE
      turn_ratio = 0
    end
    
    if @duration[:rotations]
      tacho_limit = @duration[:rotations] * 360
    end
    
    if @duration[:degrees]
      tacho_limit = @duration[:degrees]
    end
    
    if @duration[:seconds] or @duration[:unlimited]
      tacho_limit = 0
    end
    
    if @ports.include?(:a) and @ports.include?(:b) and @ports.include?(:c)
      @nxt.set_output_state(
        NXTComm::MOTOR_ALL,
        motor_power,
        mode,
        reg_mode,
        turn_ratio,
        run_state,
        tacho_limit
      )
    else
      @ports.each do |p|
        @nxt.set_output_state(
          NXTComm.const_get("MOTOR_#{p.to_s.upcase}"),
          motor_power,
          mode,
          reg_mode,
          turn_ratio,
          run_state,
          tacho_limit
        )
      end
    end
    
    unless @duration[:unlimited]
      if @duration[:seconds]
        sleep(@duration[:seconds])
      else
        until self.run_state[@ports[0]] == NXTComm::MOTOR_RUN_STATE_IDLE
          sleep(0.25)
        end
      end
      self.stop
    end
  end
  
  # stop the Move command based on the next_action property
  def stop
    if @next_action == :brake
      if @ports.include?(:a) and @ports.include?(:b) and @ports.include?(:c)
        @nxt.set_output_state(
          NXTComm::MOTOR_ALL,
          0,
          NXTComm::MOTORON | NXTComm::BRAKE | NXTComm::REGULATED,
          NXTComm::REGULATION_MODE_MOTOR_SPEED,
          0,
          NXTComm::MOTOR_RUN_STATE_RUNNING,
          0
        )
      else
        @ports.each do |p|
          @nxt.set_output_state(
            NXTComm.const_get("MOTOR_#{p.to_s.upcase}"),
            0,
            NXTComm::MOTORON | NXTComm::BRAKE | NXTComm::REGULATED,
            NXTComm::REGULATION_MODE_MOTOR_SPEED,
            0,
            NXTComm::MOTOR_RUN_STATE_RUNNING,
            0
          )
        end
      end
    else
      if @ports.include?(:a) and @ports.include?(:b) and @ports.include?(:c)
        @nxt.set_output_state(
          NXTComm::MOTOR_ALL,
          0,
          NXTComm::COAST,
          NXTComm::REGULATION_MODE_IDLE,
          0,
          NXTComm::MOTOR_RUN_STATE_IDLE,
          0
        )
      else
        @ports.each do |p|
          @nxt.set_output_state(
            NXTComm.const_get("MOTOR_#{p.to_s.upcase}"),
            0,
            NXTComm::COAST,
            NXTComm::REGULATION_MODE_IDLE,
            0,
            NXTComm::MOTOR_RUN_STATE_IDLE,
            0
          )
        end
      end
    end
  end
  
  # attempt to return the output_state requested
  def method_missing(cmd)
    states = {}
    @ports.each do |p|
      states[p] = @nxt.get_output_state(NXTComm.const_get("MOTOR_#{p.to_s.upcase}"))[cmd]
    end
    states
  end
  
end