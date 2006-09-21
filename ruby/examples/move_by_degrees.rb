#!/usr/bin/env ruby -w

require "nxt_comm"

$DEBUG = false

@nxt = NXTComm.new('/dev/tty.NXT-DevB-1')
@degrees = 360
@motor = NXTComm::MOTOR_B

# set the tacho_count = 0
@nxt.reset_motor_position(@motor)

puts @nxt.get_output_state(@motor).inspect

# ramps up to (close to) requested degrees and then if no other command is sent, it will 
# try to return to the requested degrees if force moves motor

# have to start at least power = 1 to ramp up
@nxt.set_output_state(@motor,1,NXTComm::MOTORON | NXTComm::BRAKE | NXTComm::REGULATED,
  NXTComm::REGULATION_MODE_MOTOR_SPEED,0,NXTComm::MOTOR_RUN_STATE_RUNNING,0)

# ramp up to the requested degrees
@nxt.set_output_state(@motor,75,NXTComm::MOTORON | NXTComm::BRAKE | NXTComm::REGULATED,
  NXTComm::REGULATION_MODE_MOTOR_SPEED,0,NXTComm::MOTOR_RUN_STATE_RAMPUP,@degrees)

until @nxt.get_output_state(@motor)[:run_state] == NXTComm::MOTOR_RUN_STATE_IDLE
  puts @nxt.get_output_state(@motor).inspect
  sleep(0.5)
end

# abruptly break and use power to prevent movement
# @nxt.set_output_state(@motor,0,NXTComm::MOTORON | NXTComm::BRAKE | NXTComm::REGULATED,
# NXTComm::REGULATION_MODE_MOTOR_SPEED,0,NXTComm::MOTOR_RUN_STATE_RUNNING,0)

# coast to a stop and allow force to move motor
# @nxt.set_output_state(@motor,0,NXTComm::COAST,
#   NXTComm::REGULATION_MODE_IDLE,0,NXTComm::MOTOR_RUN_STATE_IDLE,0)

puts @nxt.get_output_state(@motor).inspect

@nxt.close
