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

require 'logger'
require 'yaml'
require 'thread'

require 'brick'

Logger::Formatter::Format = "%s, [%s#%d] %5s -- %s:\n%s\n"

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
	attr_reader :port
	attr_reader :log

	def initialize(port, dev = $DEV)
		super(port, dev)
		
		@mutex = Mutex.new
		@state_access = ConditionVariable.new
		@action_access = ConditionVariable.new
		
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
	# The data available is as follows:
	# [+:port+] Motor's port. This will always be equal to +self.port+. 
	# [+:power+] Current power setting. 0 to 100.
	# [+:mode+] Current output mode. See NXTComm constants.
	# [+:regulation+] Current power regulation mode. See NXTComm constants.
	# [+:ratio+] Gear scaling ratio. This should always be equal to +self.ratio+.
	# [+:run_state+] Current output run state. See NXTComm constants.
	# [+:degree_limit+] The rotation limit previously set. 0 means no limit.
	# [+:tacho_count+] Internal tachometer count.
	# [+:tacho_count_block+] Total relative rotation count (for the motor or the nxt??)
	# [+:degree_count+] The total relative degrees turned since the last Motor#reset_tacho call.
	# 									Turning backwards adds negative values, so this can go negative.
	def state
		debug(nil, :state)
		@log.debug(:state) {"updating state"}
		t = update_state
		@log.debug(:state) {"waiting for updated state"}
		@log.debug(:state) {"got updated state"}
			
		return @state
	end
	
	
	### low level commands ######################################################
	
	# Closes the connection to the NXT and to other resources.
	def disconnect
		@nxt.stop
		@log.close
	end
	
	# Low-level command for initiating motor rotation.
	# Options is a hash with the following keys:
	# [+:power+] Power from 0 to 100. Default is 25.
	# [+:time+] Maximum time to run the motor in seconds. 
	# 					By default there is no time limit.
	# 					If :degrees is also specified then the motor
	# 					will only turn as far as :degrees and will stop and
	# 					wait out the remaining :time has expired.
	# [+:regulate+] False to disable power regulation. It is true (i.e. on)
	# 					by default.
	# [+:degrees+] The maximum tachometer degrees to turn before automatically
	# 					stopping. Use negative values for backward movement (need to
	# 					double check that this is in fact true)
	# [+:direction+] Direction in which the motor should move. 1 for forward,
	# 					-1 for backward. The default is 1 (i.e. forward).
	# 
	# Examples:
	# 
	# 	m.run(:degrees => 90, :direction => -1)
	# 
	# The above will rotate backward up to 90 degrees.
	# 
	#   m.run(:time => 8, :power => 100)
	# 
	# The above will rotate forward for 8 seconds at 100% power.
	# 
	# 	m.run(:power => 50, :degrees => 180, :time => 3)
	# 
	# The above will rotate forward for 3 seconds up to 180 degrees at 50% power.
	# If the 180 degree rotation takes only 1 second to complete, the motor will
	# sit there and wait out the full 3 seconds anyway.
	# 
	#   m.run
	#   
	# The above will rotate forward indefinitely (until +m.stop+ is called).
	def run(options)
		debug(options, :run)
	
		if options[:power]
			power = options[:power].to_i.abs
		else
			power = 25
		end
		
		time = options[:time] || nil
		regulate = options[:regulate] || true
		degrees = options[:degrees] || 0
		ratio = options[:ratio] || self.ratio
		direction = options[:direction] || 1 # 1 is forward, -1 is backward
		
		power = direction * power
		
		mode = NXTComm::MOTORON | NXTComm::BRAKE
		mode |= NXTComm::REGULATED if regulate

		@log.debug(:run) {"sending run command"}
		@nxt.SetOutputState(@port, power, mode, NXTComm::REGULATION_MODE_IDLE, ratio, NXTComm::MOTOR_RUN_STATE_RUNNING, degrees)
  
	  if time.nil?
			update_state
			@log.debug(:run) {"sleeping until run_state is idle"}
			until @state[:run_state] == NXTComm::MOTOR_RUN_STATE_IDLE
				sleep(POLL_INTERVAL)
				update_state
				@log.debug(:run) {"checking run_state again"}
			end
			@log.debug(:run) {"run_state is idle"}
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
		@nxt.SetOutputState(@port, 100, NXTComm::BRAKE, NXTComm::REGULATION_MODE_MOTOR_SPEED, 100, NXTComm::MOTOR_RUN_STATE_IDLE, 0)
	end
	
	# Resets the motor's tachometer movement count (i.e. +:degree_count+ in Motor#state).
	def reset_tacho
		@log.debug(:reset_tacho) { "resetting tacho" }
		@nxt.ResetMotorPosition(@port, false)
		@log.debug(:reset_tacho) { "reset tacho" }
	end
	
	# Updates the motor state info by requesting new
	# data from the nxt. This is mostly used internally;
	# you should use Motor#state instead.
	def update_state
		@log.debug(:update_state) { "getting state"}
		r = @nxt.GetOutputState(@port)
		@log.debug(:update_state) { "got state" }
	
		@state = {
			:port => r[0],
			:power => r[1],
			:mode => r[2],
			:regulation => r[3],
			:ratio => r[4],
			:run_state => r[5],
			:degree_limit => r[6],
			:tacho_count => r[7],
			:tacho_count_block => r[8],
			:degree_count => r[9]
		}
		
		debug(@state, :update_state)
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


#$DEV = '/dev/tty.NXT-DevB-1'
#motor_a = Motor.new('a')
#
#motor_a.forward(:degrees => 65, :power => 15, :regulated => true)
#puts motor_a.state.to_yaml