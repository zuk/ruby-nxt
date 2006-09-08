#!/usr/local/bin/ruby

require 'nxt_comm'
require 'yaml'

$DEBUG = false

NXTComm.exec("/dev/tty.NXT-DevB-1") do |cmd|

  # StartProgram(filename)
  # cmd.StartProgram("Try-Touch.rtm")

  # StopProgram - stops any currently running programs
  # cmd.StopProgram

  # PlaySoundFile(loop?,filename)
  # cmd.PlaySoundFile(false,"Good Job.rso")

  # PlayTone(frequency,duration)
  # cmd.PlayTone(50,500)
  
  # SetOutputState(port,power,mode,regulation,turn ratio,run state,tacho limit)
#   cmd.SetOutputState(
#     NXTComm::MOTOR_B,
#     100,
#     NXTComm::MOTORON | NXTComm::BRAKE | NXTComm::REGULATED,
#     NXTComm::REGULATION_MODE_MOTOR_SPEED,
#     100,
#     NXTComm::MOTOR_RUN_STATE_RUNNING,
#     0
#   )
#   sleep(5)
#   cmd.SetOutputState(
#     NXTComm::MOTOR_B,
#     100,
#     NXTComm::MOTORON | NXTComm::BRAKE | NXTComm::REGULATED,
#     NXTComm::REGULATION_MODE_MOTOR_SPEED,
#     0,
#     NXTComm::MOTOR_RUN_STATE_RAMPDOWN,
#     0
#   )

  # SetInputMode(port,type,mode)
  cmd.SetInputMode(NXTComm::SENSOR_3,NXTComm::LIGHT_INACTIVE,NXTComm::RAWMODE)
  
  while true
	  s = cmd.GetInputValues(NXTComm::SENSOR_3)
	  
	  puts s.inspect
	  sleep(1)
  end
  
   #GetOutputState(motor_port)
  #puts "GetOutputState: #{cmd.GetOutputState(NXTComm::MOTOR_B)}"
  
  # GetInputValues(sensor_port)
  # cmd.GetInputValues(NXTComm::SENSOR_1)
  
  # ResetInputScaledValue(sensor_port)
  # cmd.ResetInputScaledValue(NXTComm::SENSOR_1)
  
  # MessageWrite(mailbox,message)
  # cmd.MessageWrite(1,"Chunky Robotic Bacon!")
  
  # ResetMotorPosition(motor_port,relative?)
  # cmd.ResetMotorPosition(NXTComm::MOTOR_B,false)
  
  # GetBatteryLevel
  #puts "Battery Level: #{cmd.GetBatteryLevel[0]/1000.0} V"
  
  # StopSoundPlayback - stops any currently playing sounds
  #cmd.PlaySoundFile(true,"Woops.rso")
  #sleep(3)
  #cmd.StopSoundPlayback
  
end
