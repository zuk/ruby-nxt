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

# Implements the "Move" block in NXT-G
class Commands::Move

  include Commands::Mixins::Motor 
  
  attr_reader   :ports
  attr_accessor :direction
  attr_accessor :left_motor, :right_motor
  attr_accessor :power
  attr_accessor :next_action
  
  def initialize(nxt = NXTComm.new($DEV))
    @nxt          = nxt
    
    # defaults the same as NXT-G
    @ports        = [:b, :c]
    @direction    = :forward
    @power        = 75
    @duration     = {:rotations => 1}
    @next_action  = :brake
    self.turn_ratio = :straight
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
  alias port= ports=

  def turn_ratio=(turn_ratio)
    # simplified steering... if the user wants fine control, they should just specify -100 to 100
    case turn_ratio
      when :straight then @turn_ratio = 0
      when :spin_left then @turn_ratio = -100
      when :spin_right then @turn_ratio = 100
      when :left then @turn_ratio = -50
      when :right then @turn_ratio = 50
      else @turn_ratio = turn_ratio
    end

    # DEPRECATED: for backwards compatibility we parse the argument as a hash... I think though that this should be deprecated
    if turn_ratio.kind_of? Hash
      old_steering = turn_ratio
      self.left_motor = old_steering[:left_motor] if old_steering.has_key? :left_motor
      self.right_motor = old_steering[:right_motor] if old_steering.has_key? :right_motor
      if old_steering[:power]
        self.turn_ratio = old_steering[:power] * (old_steering[:direction] == :left ? -1 : 1)
      else
        self.turn_ratio = old_steering[:direction]
      end
    end
  end
  alias steering= turn_ratio=

  def turn_ratio
    if @ports.size > 1
      @turn_ratio
    else
      0
    end
  end
  alias steering turn_ratio
  

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
    else
      reg_mode = NXTComm::REGULATION_MODE_IDLE
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
    
    unless @duration.nil?
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
