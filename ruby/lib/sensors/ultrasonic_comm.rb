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


# Low-level interface for communicating with the NXT's Ultrasonic
# sensor. Unlike the other sensors, the Ultrasonic sensor is digital
# and uses the low-speed I2C protocol for communication. This is
# defined in Appendix 7 of the Lego Mindstorms NXT SDK. 
class UltrasonicComm

  @@i2c_dev = 0x02

  # first value is the i2c address, second value is the expected number of bytes returned
  @@const_codes = {
    'read_version'               => [0x00, 8],
    'read_product_id'            => [0x08, 8],
    'read_sensor_type'           => [0x10, 8],
    'read_factory_zero'          => [0x11, 1],
    'read_factory_scale_factor'  => [0x12, 1],
    'read_factory_scale_divisor' => [0x13, 1],
    'read_measurement_units'     => [0x14, 7],
  }
  
  # value is the i2c address (all of these ops always expect to return 1 byte)
  @@var_codes = {  
    'read_continuous_measurements_interval'  => 0x40,
    'read_command_state'         => 0x41,
    'read_measurement_byte_0'     => 0x42,
    'read_measurement_byte_1'     => 0x43,
    'read_measurement_byte_2'     => 0x44,
    'read_measurement_byte_3'     => 0x45,
    'read_measurement_byte_4'     => 0x46,
    'read_measurement_byte_5'    => 0x47,
    'read_measurement_byte_6'    => 0x48,
    'read_measurement_byte_7'    => 0x49,
    'read_actual_zero'           => 0x50,
    'read_actual_scale_factor'   => 0x51,
    'read_actual_scale_divisor'  => 0x52,
  }
  
  # first value is the i2c address, second value is the command
  @@cmd_codes = {
    'off_command'                         => [0x41, 0x00],
    'single_shot_command'                 => [0x41, 0x01],
    'continuous_measurement_command'      => [0x41, 0x02],
    'event_capture_command'               => [0x41, 0x03],
    'request_warm_reset'                  => [0x41, 0x04],
    'set_continuous_measurement_interval' => [0x40],
    'set_actual_zero'                     => [0x50],
    'set_actual_scale_factor'             => [0x51],
    'set_actual_scale_divisor'            => [0x52]
  }
  
      
  def self.read_measurement_byte(num)
    eval "self.read_measurement_byte_#{num}"
  end
  
  def self.method_missing(name, *args)
    name = name.to_s
    if @@const_codes.has_key? name
      type = :const
      op = @@const_codes[name]
      addr = op[0]
      rx_len = op[1]
    elsif @@var_codes.has_key? name
      type = :var
      op = @@var_codes[name]
      addr = op
      rx_len = 1
    elsif @@cmd_codes.has_key? name
      type = :cmd
      op = @@cmd_codes[name]
      addr = op[0]
      if op[1] then value = op[1]
      elsif args[0] then value = args[0]
      else raise "Missing argument for command #{name}" end
      rx_len = 0
    else
      raise "Unknown ultrasonic sensor command: #{name}"
    end

    data = [@@i2c_dev, addr]
    data += [value] if type == :cmd
    
    [data.size, rx_len] + data
  end

end
