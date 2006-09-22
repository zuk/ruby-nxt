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

require File.dirname(File.expand_path(__FILE__))+'/brick'


# Controls an NXT motor.
# 
# Example:
# 
#   m = Motor.new('a')
#   m.forward(:degrees => 180, :power => 50)
#   
class Motor < Brick
  
  POLL_INTERVAL = 0.5
  
  attr_accessor :ratio
  
  def initialize(nxt, port)
    super(nxt, port)
    
    @port = formalize_motor_port_name(port)
    
    @ratio = 0
  end
  
  def name
    case self.port
      when NXTComm::MOTOR_A then 'a'
      when NXTComm::MOTOR_B then 'b'
      when NXTComm::MOTOR_C then 'c'
    end
  end
  
  ### high level commands #####################################################
  
  # Rotate the motor forwards.
  # See Motor#run.
  # Examples:
  # 
  #   m.forward(:degrees => 360, :power => 20)
  #
  # The above rotates the motor 360 degrees forward at 20% power.
  #
  #   m.forward(:time => 5) 
  #   
  # The above rotates the motor forwards for 5 seconds at 25% power
  # (because 25% is the default). 
  def forward(options)
    debug(options.to_yaml, :forward)
    options[:direction] = 1
    return run(options)
  end
  
  # Rotate the motor backwards.
  # See Motor#forward and Motor#run.
  def backward(options)
    debug(options, :backward)
    options[:direction] = -1
    return run(options)
  end
  
  # Return the current state of the motor as a hash.
  # See NXTComm#get_output_state for info on what data is available here.
  def read_state
    @log.debug(:read_state) { "getting state"}
    state = @nxt.get_output_state(@port)
    @log.debug(:read_state) { "got state" }
    
    debug(state, :state)
    
    return state
  end
  
  
  ### low level commands ######################################################
  
  # Low-level command for initiating motor rotation.
  # Options is a hash with the following keys:
  # [+:power+] Power from 0 to 100. Default is 25.
  # [+:time+] Maximum time to run the motor in seconds. 
  #           By default there is no time limit.
  #           If :degrees is also specified then the motor
  #           will only turn as far as :degrees and will stop and
  #           wait out the remaining :time has expired.
  # [+:regulate+] False to disable power regulation. It is true (i.e. on)
  #           by default.
  # [+:degrees+] The maximum tachometer degrees to turn before automatically
  #           stopping. Use negative values for backward movement (need to
  #           double check that this is in fact true)
  # [+:direction+] Direction in which the motor should move. 1 for forward,
  #           -1 for backward. The default is 1 (i.e. forward).
  # [+:wait_until_complete+] If true, the motor will block further commands
  # 					until this command is complete. This is true by default when
  # 					:degrees or :time is specified, false by default otherwise.
  # 					NOTE: currently this setting is always on and cannot be turned off
  # 					when :time is specified... this will probably be fixed in the future
  # [+:brake_on_stop+] If true, the motor will try to hard brake when the
  # 					command completes (otherwise when the command finishes the
  # 					motor may continue to coast for a while -- especially at higher
  # 					power levels). This is true by default when :degrees or :time
  # 					is specified, false by default otherwise.
  # 
  # 
  # ====Examples:
  # 
  # Rotate backward up to 90 degrees:
  # 
  #   m.run(:degrees => 90, :direction => -1)
  # 
  # Rotate forward for 8 seconds at 100% power:
  # 
  #   m.run(:time => 8, :power => 100)
  # 
  # Forward for 3 seconds up to 180 degrees at 50% power. If the 180 degree 
  # rotation takes only 1 second to complete, the motor will
  # sit there and wait out the full 3 seconds anyway:
  # 
  #   m.run(:power => 50, :degrees => 180, :time => 3)
  # 
  # Rotate forward indefinitely (until Motor#stop is called).
  # 
  #   m.run
  #   
  def run(options)
    debug(options, :run)
  
    if options[:power]
      power = options[:power].to_i.abs
    else
      power = 25
    end
    
    time = options[:time] || nil
    regulate = options[:regulate] || true
    regulation_mode = options[:regulation_mode] || "speed"
    degrees = options[:degrees] || 0
    ratio = options[:ratio] || self.ratio
    direction = options[:direction] || 1 # 1 is forward, -1 is backward

    brake_on_stop = options.has_key?(:time) || options.has_key?(:degrees)
    wait_until_complete = options.has_key?(:time) || options.has_key?(:degrees)
    
    brake_on_stop = options[:brake_on_stop] if options.has_key?(:brake_on_stop)

    wait_until_complete = options[:wait_until_complete] if options.has_key?(:wait_until_complete)
    # FIXME: wait_until_complete MUST be true if a time period is specified, otherwise we have no way of
    # 				enforcing the time limit (this is a problem with the way threading is implemented...)
    wait_until_complete = true if options.has_key?(:time)
    
    power = direction * power
    
    mode = NXTComm::MOTORON
    mode |= NXTComm::BRAKE if brake_on_stop
    mode |= NXTComm::REGULATED if regulate
    
    if regulate
      case regulation_mode
	      when "idle"
	        regulation_mode = NXTComm::REGULATION_MODE_IDLE
        when "speed"
    	    regulation_mode = NXTComm::REGULATION_MODE_MOTOR_SPEED
	      when "sync"
	        regulation_mode = NXTComm::REGULATION_MODE_MOTOR_SYNC
      end
    else
    	regulation_mode = NXTComm::REGULATION_MODE_IDLE
    end

    @log.debug(:run) {"sending run command"}
    @nxt.set_output_state(@port, power, mode, regulation_mode, ratio, NXTComm::MOTOR_RUN_STATE_RUNNING, degrees)
  
    if time.nil?
    	if wait_until_complete
	      @log.debug(:run) {"sleeping until run_state is idle"}
	      until read_state[:run_state] == NXTComm::MOTOR_RUN_STATE_IDLE
	        sleep(POLL_INTERVAL)
	        @log.debug(:run) {"checking run_state again"}
	      end
	      @log.debug(:run) {"run_state is idle"}
    	end
    else
      @log.debug(:run) {"waiting #{time} seconds until stop"}
      sleep(time)
      @log.debug(:run) {"stopping"}
      self.stop
      @log.debug(:run) {"stopped"}
    end
  end
  
  # Stop movement.
  def stop
    debug(nil, :stop)
    @nxt.set_output_state(@port, 100, NXTComm::BRAKE, NXTComm::REGULATION_MODE_MOTOR_SPEED, 100, NXTComm::MOTOR_RUN_STATE_IDLE, 0)
  end
  
  # Resets the motor's tachometer movement count (i.e. +:degree_count+ in Motor#state).
  def reset_tacho
    @log.debug(:reset_tacho) { "resetting tacho" }
    @nxt.reset_motor_position(@port, false)
    @log.debug(:reset_tacho) { "reset tacho" }
  end
  
  private
    def formalize_motor_port_name(port)
      port = port.downcase.intern if port.kind_of? String
    
      if port.kind_of? Symbol
        case port
          when :a then return NXTComm::MOTOR_A
          when :b then return NXTComm::MOTOR_B
          when :c then return NXTComm::MOTOR_C
        end
      elsif [NXTComm::MOTOR_A, NXTComm::MOTOR_B, NXTComm::MOTOR_C].include? port
        return port
      else
        raise "'#{port}' is not a valid motor port"
      end
    end

end