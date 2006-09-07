# ruby-nxt Control Mindstorms NXT via Bluetooth Serial Port Connection
# Copyright (C) 2006 Tony Buser <tbuser@gmail.com> - juju.org
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

# http://raa.ruby-lang.org/project/ruby-serialport/
require "serialport"
require "thread"

class Array
  def to_hex_str
    self.collect{|e| "0x%02x " % e}
  end
end

class String
  def to_hex_str
    str = ""
    self.each_byte {|b| str << '0x%02x ' % b}
    str
  end
  
  def from_hex_str
  	data = self.split(' ')
  	str = ""
  	data.each{|h| eval "str += '%c' % #{h}"}
  	str
  end
end

class Bignum
  # This is needed because String#unpack() can't handle little-endian signed longs...
  # instead we unpack() as a little-endian unsigned long (i.e. 'V') and then use this
  # method to convert to signed long.
  def as_signed
  	-1*(self^0xffffffff) if self > 0xfffffff
  end
end

# Low-level interface for communicating directly with the NXT via
# a Bluetooth serial port.
# 
# Not all functionality is implemented yet!
# 
# Examples:
# 
# 	NXTComm.exec("/dev/tty.NXT-DevB-1") do |cmd|
# 	  cmd.SetOutputState(
#       NXTComm::MOTOR_B,
#       100,
#       NXTComm::MOTORON | NXTComm::BRAKE | NXTComm::REGULATED,
#       NXTComm::REGULATION_MODE_MOTOR_SPEED,
#       100,
#       NXTComm::MOTOR_RUN_STATE_RUNNING,
#       0
#     )
#   end
# 
# The above would rotate the motor connected to port B forwards indefinitely at 100% power. 
# 
#   cmd.PlayTone(1000,500)
#   
# The above would play a tone at 1000 Hz (??) for 500 ticks (half a second??)
# 
#   puts "Battery Level: #{cmd.GetBatteryLevel[0]/1000.0} V"
# 
# The above would print out the current battery level (obviously).
# 
class NXTComm

	@@devs = {}

  # sensors
  SENSOR_1  = 0x00
  SENSOR_2  = 0x01
  SENSOR_3  = 0x02
  SENSOR_4  = 0x03
  
  # motors
  MOTOR_A   = 0x00
  MOTOR_B   = 0x01
  MOTOR_C   = 0x02
  MOTOR_ALL = 0xFF
  
  # output mode
  IDLE		= 0x01
  MOTORON   = 0x01
  BRAKE     = 0x02
  REGULATED = 0x04
  
  # output regulation mode
  REGULATION_MODE_IDLE        = 0x00
  REGULATION_MODE_MOTOR_SPEED = 0x01
  REGULATION_MODE_MOTOR_SYNC  = 0x02
  
  # output run state
  MOTOR_RUN_STATE_IDLE        = 0x00
  MOTOR_RUN_STATE_RAMPUP      = 0x10
  MOTOR_RUN_STATE_RUNNING     = 0x20
  MOTOR_RUN_STATE_RAMPDOWN    = 0x40
  
  # sensor type
  NO_SENSOR           = 0x00
  SWITCH              = 0x01
  TEMPERATURE         = 0x02
  REFLECTION          = 0x03
  ANGLE               = 0x04
  LIGHT_ACTIVE        = 0x05
  LIGHT_INACTIVE      = 0x06
  SOUND_DB            = 0x07
  SOUND_DBA           = 0x08
  CUSTOM              = 0x09
  LOWSPEED            = 0x0A
  LOWSPEED_9V         = 0x0B
  NO_OF_SENSOR_TYPES  = 0x0C
  
  # sensor mode
  RAWMODE             = 0x00
  BOOLEANMODE         = 0x20
  TRANSITIONCNTMODE   = 0x40
  PERIODCOUNTERMODE   = 0x60
  PCTFULLSCALEMODE    = 0x80
  CELSIUSMODE         = 0xA0
  FAHRENHEITMODE      = 0xC0
  ANGLESTEPSMODE      = 0xE0
  SLOPEMASK           = 0x1F
  MODEMASK            = 0xE0
  
  @@op_codes = {
    'StartProgram'          => [0x00, proc{|n|a=[];n.each_byte{|b| a << b};a}, proc{[]} ],
    'StopProgram'           => [0x01, proc{[]}, proc{[]} ],
    'PlaySoundFile'         => [0x02, proc{|l,n|a=[];l ? a << 0x01 : a << 0x00;n.each_byte{|b| a << b};a}, proc{[]} ],
    'PlayTone'              => [0x03, proc{|f,d|[(f & 255),(f >> 8),(d & 255),(d >> 8)]}, proc{[]} ],
    'SetOutputState'        => [0x04, proc{|op,p,m,rm,tr,rs,tl|[op,p,m,rm,tr,rs] + [tl].pack("V").unpack("C4")}, proc{[]} ],
    'SetInputMode'          => [0x05, proc{|sp,st,sm|[sp,st,sm]}, proc{[]}],
    'GetOutputState'        => [0x06, proc{|p|[p]}, proc{|r|a=r.from_hex_str.unpack('C6VVVV');(7..9).each{|i| a[i]= a[i].as_signed if a[i].kind_of? Bignum };a}],
    'GetInputValues'        => [0x07, proc{|p|[p]}, proc{[]}],
    'ResetInputScaledValue' => [0x08, proc{|p|[p]}, proc{[]}],
    'MessageWrite'          => [0x09, proc{|b,m|a=[];a << b-1;a << m.size+1;m.each_byte{|b| a << b};a}, proc{[]}],
    'ResetMotorPosition'    => [0x0A, proc{|p,r|a=[];a << p;r ? a << 0x01 : a << 0x00;a}, proc{[]}],
    'GetBatteryLevel'       => [0x0B, proc{[]}, proc{|r|[r.from_hex_str.unpack("v")[0]]} ],
    'StopSoundPlayback'     => [0x0C, proc{[]}, proc{[]} ],
    'KeepAlive'             => [0x0D, proc{[]}, proc{[]}]
  }
  
  @@error_codes = {
    0x20 => ["Pending communication transaction in progress"],
    0x40 => ["Specified mailbox queue is empty"],
    0xBD => ["Request failed (i.e. specified file not found)"],
    0xBE => ["Unknown command opcode"],
    0xBF => ["Insane packet"],
    0xC0 => ["Data contains out-of-range values"],
    0xDD => ["Communication bus error"],
    0xDE => ["No free memory in communication buffer"],
    0xDF => ["Specified channel/connection is not valid"],
    0xE0 => ["Specified channel/connection not configured or busy"],
    0xEC => ["No active program"],
    0xED => ["Illegal size specified"],
    0xEE => ["Illegal mailbox queue ID specified"],
    0xEF => ["Attempted to access invalid field of a structure"],
    0xF0 => ["Bad input or output specified"],
    0xFB => ["Insufficient memory available"],
    0xFF => ["Bad arguments"]
  }
  
  def self.connect(dev)	    
    # we need to keep track of connections to make sure we don't have multiple instances of
    # NXTComm talking to the same serial port
    
    if @@devs.include? dev
    	@@devs[dev]
    else
    	@@devs[dev] = NXTComm.new(dev)
    end
  end
  
  def start
  	begin
    	@sp = SerialPort.new(@dev, 57600, 8, 1, SerialPort::NONE)
    rescue Errno::EBUSY
    	raise "Cannot connect to #{@dev}. The serial port is busy or unavailable."
    end
    
    @sp.flow_control = SerialPort::HARD
    @sp.read_timeout = 5000
    
    @mutex = Mutex.new
    
    if @sp.nil?
      $stderr.puts "Cannot connect to #{@dev}"
      return 1
    else
      puts "Connected to: #{@dev}" if $DEBUG
    end
    0
  end

  def stop
  	# FIXME: @sp seems to be nil sometimes for some reason...
    @sp.close if @sp and not @sp.closed?
    0
  end
  
  def self.exec(dev)
    cmd = NXTComm.connect(dev)
    cmd.start
    yield cmd
  ensure
    cmd.stop
  end
  
  def method_missing(name,*arg)
    val = nil
    cmd_str = name.id2name
    op = @@op_codes[cmd_str]
    if op
      msg = [op[0]] + op[1].call(*arg) + [0x00]
      self.send_cmd(msg)
      len,ret = self.recv_reply
      
      if (ret[1] == op[0])
        data = ret[3..ret.size]
        # if data contains a \n character, ruby seems to pass the parts before and after the \n
        # as two different parameters... we need to encode the data into a format that doesn't
        # contain any \n's and then decode it in the receiving method
        data = data.to_hex_str
        val = op[2].call(*data)
      else
        puts "Could not decode returned msg for #{cmd_str}"
      end
    else
      puts "ERROR: Unknown command #{cmd_str}"
    end
    
    val
  end
  
  def send_cmd(msg)
  	@mutex.synchronize do
	  	msg = [0x00] + msg # always request a response
	    puts "Message Size: #{msg.size}" if $DEBUG
	    msg = [(msg.size & 255),(msg.size >> 8)] + msg
	    puts "Sending Message: #{msg.to_hex_str}" if $DEBUG
	    msg.each do |b|
	      @sp.putc b
	    end
	  end
  end
  
  def recv_reply
  	@mutex.synchronize do
	    while (len_header = @sp.sysread(2))
	      msg = @sp.sysread(len_header.unpack("v")[0])
	      puts "Received Message: #{msg.to_hex_str}" if $DEBUG
	      
	      if msg[0] != 0x02
	        puts "ERROR: Returned something other then a reply telegram"
	        return [0,msg]
	      end
	      
	      if msg[2] != 0x00
	        puts "ERROR: #{@@error_codes[msg[2]]}"
	        return [0,msg]
	      end
	      
	      return[msg.size,msg]
	    end
    end
  end
  
  # keep the constructor hidden since we use #connect as a factory method 
  private
	  def initialize(dev)
	    @dev = dev
	    @sp = nil
	  end
  
end
