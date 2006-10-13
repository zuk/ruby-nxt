#!/usr/bin/env ruby

require "tk"
require "nxt"

class NXTRemoteControl
  
  def initialize
    @nxt  = NXTComm.new($DEV)
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
    @m = Commands::Move.new(@nxt)
    @m.start
  end
  
  def backward
    @text.value = "Moving backward..."
    @m = Commands::Move.new(@nxt)
    @m.direction = :backward
    @m.start
  end
  
  def left
    @text.value = "Turning left"
    @m = Commands::Move.new(@nxt)
    @m.steering = :left
    @m.start
  end
  
  def right
    @text.value = "Turning right"
    @m = Commands::Move.new(@nxt)
    @m.steering = :right
    @m.start
  end
  
  def stop
    @text.value = "Stopping"
    @m = Commands::Move.new(@nxt)
    @m.stop
  end
end

NXTRemoteControl.new
Tk.mainloop
