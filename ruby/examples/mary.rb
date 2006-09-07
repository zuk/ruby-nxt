#!/usr/local/bin/ruby

# Plays "Mary Had A Little Lamb"
# Author: Christopher Continanza <christopher.continanza@villanova.edu>

require 'nxt_comm'

$DEBUG = true

def sleeper
 sleep(0.5)
end

NXTComm.exec("/dev/tty.NXT-DevB-1") do |cmd|

  #E  D C   D E   E  E
  cmd.PlayTone(659,500)
  sleeper
  cmd.PlayTone(587,500)
  sleeper
  cmd.PlayTone(523,500)
  sleeper
  cmd.PlayTone(587,500)
  sleeper
  cmd.PlayTone(659,500)
  sleeper
  cmd.PlayTone(659,500)
  sleeper
  cmd.PlayTone(659,500)
  sleeper
  sleeper
  #D  D   D     E   G  G
  cmd.PlayTone(587,500)
  sleeper
  cmd.PlayTone(587,500)
  sleeper
  cmd.PlayTone(587,500)
  sleeper
  sleeper
  cmd.PlayTone(659,500)
  sleeper
  cmd.PlayTone(784,500)
  sleeper
  cmd.PlayTone(784,500)
  sleeper
  sleeper
  #E  D C   D E   E  E
  cmd.PlayTone(659,500)
  sleeper
  cmd.PlayTone(587,500)
  sleeper
  cmd.PlayTone(523,500)
  sleeper
  cmd.PlayTone(587,500)
  sleeper
  cmd.PlayTone(659,500)
  sleeper
  cmd.PlayTone(659,500)
  sleeper
  cmd.PlayTone(659,500)
  sleeper
  #E    D      D   E     D  C
  cmd.PlayTone(659,500)
  sleeper
  cmd.PlayTone(587,500)
  sleeper
  cmd.PlayTone(587,500)
  sleeper
  cmd.PlayTone(659,500)
  sleeper
  cmd.PlayTone(587,500)
  sleeper
  cmd.PlayTone(523,750)
  sleeper
  sleeper
  sleeper

end
