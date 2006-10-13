#!/usr/local/bin/ruby

# Plays "Mary Had A Little Lamb"
# Author: Christopher Continanza <christopher.continanza@villanova.edu>

require "nxt_comm"

$DEBUG = true

def sleeper
 sleep(0.5)
end

@nxt = NXTComm.new("/dev/tty.NXT-DevB-1")

#E  D C   D E   E  E
@nxt.play_tone(659,500)
sleeper
@nxt.play_tone(587,500)
sleeper
@nxt.play_tone(523,500)
sleeper
@nxt.play_tone(587,500)
sleeper
@nxt.play_tone(659,500)
sleeper
@nxt.play_tone(659,500)
sleeper
@nxt.play_tone(659,500)
sleeper
sleeper
#D  D   D     E   G  G
@nxt.play_tone(587,500)
sleeper
@nxt.play_tone(587,500)
sleeper
@nxt.play_tone(587,500)
sleeper
sleeper
@nxt.play_tone(659,500)
sleeper
@nxt.play_tone(784,500)
sleeper
@nxt.play_tone(784,500)
sleeper
sleeper
#E  D C   D E   E  E
@nxt.play_tone(659,500)
sleeper
@nxt.play_tone(587,500)
sleeper
@nxt.play_tone(523,500)
sleeper
@nxt.play_tone(587,500)
sleeper
@nxt.play_tone(659,500)
sleeper
@nxt.play_tone(659,500)
sleeper
@nxt.play_tone(659,500)
sleeper
#E    D      D   E     D  C
@nxt.play_tone(659,500)
sleeper
@nxt.play_tone(587,500)
sleeper
@nxt.play_tone(587,500)
sleeper
@nxt.play_tone(659,500)
sleeper
@nxt.play_tone(587,500)
sleeper
@nxt.play_tone(523,750)
sleeper
sleeper
sleeper

@nxt.close