#!/usr/bin/env ruby

require 'tk'
require File.dirname(File.expand_path(__FILE__))+'/../lib/nxt'

require File.dirname(File.expand_path(__FILE__))+'/../lib/autodetect_nxt'

class NXTRemoteControl
  
  def initialize
    @nxt  = NXT.new($DEV)
    ph    = { 'padx' => 10, 'pady' => 10 }
    root  = TkRoot.new { title "NXT Remote Control" }
    top   = TkFrame.new(root)
    
    _forward   = proc{forward}
    _backward  = proc{backward}
    _left      = proc{left}
    _right     = proc{right}
    _stop      = proc{stop}
    
    @text = TkVariable.new
    @entry = TkEntry.new(top, 'textvariable' => @text)
    @entry.pack(ph)
    
    TkButton.new(top) {text 'Forward'; command _forward; pack ph}
    TkButton.new(top) {text 'Backward'; command _backward; pack ph}
    TkButton.new(top) {text 'Left'; command _left; pack ph}
    TkButton.new(top) {text 'Right'; command _right; pack ph}
    TkButton.new(top) {text 'Stop'; command _stop; pack ph}

    TkButton.new(top) {text 'Exit'; command {proc exit}; pack ph}

    top.pack('fill'=>'both', 'side' =>'top')
  end

  def forward
    @text.value = "Moving forward..."
    @nxt.motors_ab do |m|
      m.forward(:power => 75, :regulate => true, :regulation_mode => "sync")
    end
  end
  
  def backward
    @text.value = "Moving backward..."
    @nxt.motors_ab do |m|
      m.backward(:power => 75, :regulate => true, :regulation_mode => "sync")
    end
  end
  
  def left
    @text.value = "Turning left"
    @nxt.motors_ab do |m|
      m.forward(:power => 75, :regulate => true, :ratio => -50, :regulation_mode => "sync")
    end
  end
  
  def right
    @text.value = "Turning right"
    @nxt.motors_ab do |m|
      m.forward(:power => 75, :regulate => true, :ratio => 50, :regulation_mode => "sync")
    end
  end
  
  def stop
    @text.value = "Stopping"
    @nxt.motors_ab do |m|
      m.stop
    end
  end
end

NXTRemoteControl.new
Tk.mainloop