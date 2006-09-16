#!/usr/bin/env ruby

require 'tk'
require File.dirname(__FILE__)+'/../nxt'

$DEV = '/dev/tty.NXT-DevB-1'

class NXTRemoteControl
  
  def initialize
    @nxt  = NXT.new($DEV)
    ph    = { 'padx' => 10, 'pady' => 10 }
    root  = TkRoot.new { title "NXT Remote Control" }
    top   = TkFrame.new(root)
    
    go_forward  = proc{move_forward}
    go_backward = proc{move_backward}
    go_left     = proc{turn_left}
    go_right    = proc{turn_right}
    all_stop    = proc{stop_moving}
    
    @text = TkVariable.new
    @entry = TkEntry.new(top, 'textvariable' => @text)
    @entry.pack(ph)
    
    TkButton.new(top) {text 'Forward'; command go_forward; pack ph}
    TkButton.new(top) {text 'Backward'; command go_backward; pack ph}
    TkButton.new(top) {text 'Left'; command go_left; pack ph}
    TkButton.new(top) {text 'Right'; command go_right; pack ph}
    TkButton.new(top) {text 'Stop'; command all_stop; pack ph}

    TkButton.new(top) {text 'Exit'; command {proc exit}; pack ph}

    top.pack('fill'=>'both', 'side' =>'top')
  end

  def move_forward
    @text.value = "Moving forward..."
    @nxt.motors_ab do |m|
      m.forward(:power => 100, :time => 2)
    end
  end
  
  def move_backward
    @text.value = "Moving backward..."
    @nxt.motors_ab do |m|
      m.backward(:power => 100, :time => 2)
    end
  end
  
  def turn_left
    @text.value = "Turning left"
    @nxt.motor_a {|m| m.forward(:power => 100, :degrees => 180)}
  end
  
  def turn_right
    @text.value = "Turning right"
    @nxt.motor_b {|m| m.forward(:power => 100, :degrees => 180)}
  end
  
  def stop_moving
    @text.value = "Stopping"
    @nxt.motors_ab do |m|
      m.stop
    end
  end
end

NXTRemoteControl.new
Tk.mainloop