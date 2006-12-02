require File.dirname(__FILE__) + '/../test_helper'
require "test/unit"
require "stringio"
require "nxt_comm"

$DEV = '/dev/tty.NXT-DevB-1'

# Test Setup:
# * a motor in port A
# * touch sensor in port 1
# * the default Try-Touch.rtm program needs to be on the NXT

class NXTCommTest < Test::Unit::TestCase

  @@nxt = NXTComm.new($DEV)
	
  def capture_stderr
    begin
      $stderr = StringIO.new
      yield
      $stderr.rewind && $stderr.read
    ensure
      $stderr = STDERR
    end
  end

	def test_start_stop_program
    assert @@nxt.start_program("Try-Touch.rtm")
    sleep(3)
    assert @@nxt.stop_program
	end

  def test_invalid_program_name
    err = capture_stderr { assert !@@nxt.start_program("foo") }
    assert_equal "ERROR: Data contains out-of-range values\n", err
  end

  def test_stop_program_when_nothing_running
    err = capture_stderr { assert !@@nxt.stop_program }
    assert_equal "ERROR: No active program\n", err
  end

  def test_play_sound_file
    assert @@nxt.play_sound_file("Good Job.rso")
    sleep(1)
  end

  def test_invalid_sound_file
    err = capture_stderr { assert !@@nxt.play_sound_file("foo") }
    assert_equal "ERROR: Data contains out-of-range values\n", err
  end

  def test_play_tone
    assert @@nxt.play_tone(500,300)
  end

  def test_get_and_set_output
    assert @@nxt.set_output_state(NXTComm::MOTOR_A,100,NXTComm::MOTORON,NXTComm::REGULATION_MODE_MOTOR_SPEED,100,NXTComm::MOTOR_RUN_STATE_RUNNING,0)
    state = @@nxt.get_output_state(NXTComm::MOTOR_A)
    assert_equal 100, state[:power]

    sleep(1)

    assert @@nxt.set_output_state(NXTComm::MOTOR_A,0,NXTComm::BRAKE,NXTComm::REGULATION_MODE_MOTOR_SPEED,0,NXTComm::MOTOR_RUN_STATE_RAMPDOWN,0)
    state = @@nxt.get_output_state(NXTComm::MOTOR_A)
    assert_equal 0, state[:power]
  end

  def test_get_and_set_input
    assert @@nxt.set_input_mode(NXTComm::SENSOR_1,NXTComm::SWITCH,NXTComm::RAWMODE)
    values = @@nxt.get_input_values(NXTComm::SENSOR_1)
    assert_equal 0, values[:mode]

    assert @@nxt.set_input_mode(NXTComm::SENSOR_1,NXTComm::SWITCH,NXTComm::BOOLEANMODE)
    values = @@nxt.get_input_values(NXTComm::SENSOR_1)
    assert_equal 32, values[:mode]
  end

  def test_reset_input_scaled_value
    assert @@nxt.reset_input_scaled_value(NXTComm::SENSOR_1)
  end

  def test_message_write
    err = capture_stderr { assert !@@nxt.message_write(1,"Won't work unless a program is running...") }
    assert_equal "ERROR: No active program\n", err

    # weird timing problems, can take a while to start a program it seems...
    sleep(1)
    assert @@nxt.start_program("Try-Touch.rtm")
    sleep(3)
    
    assert @@nxt.message_write(1,"Chunky Robotic Bacon!")
    
    assert @@nxt.stop_program
  end

  def test_message_read
    err = capture_stderr { assert !@@nxt.message_read(1) }
    assert_equal "ERROR: No active program\n", err

    # weird timing problems, can take a while to start a program it seems...
    sleep(1)
    assert @@nxt.start_program("Try-Touch.rtm")
    sleep(3)

    # to properly test message read, I'd need to start a program that places a message in a box...
    err = capture_stderr { assert !@@nxt.message_read(1) }
    assert_equal "ERROR: Specified mailbox queue is empty\n", err
    
    assert @@nxt.stop_program
  end

  def test_reset_motor_position
    assert @@nxt.reset_motor_position(NXTComm::MOTOR_A)
  end

	def test_get_battery_level
    result = @@nxt.get_battery_level
    assert_kind_of Fixnum, result
    assert result > 0
	end

  def test_stop_sound_playback
    assert @@nxt.play_sound_file("Good Job.rso",true)
    sleep(2)
    assert @@nxt.stop_sound_playback
  end
	
	def test_keep_alive
	  assert_equal 600000, @@nxt.keep_alive
	end
	
	def test_get_current_program_name
    err = capture_stderr { assert !@@nxt.get_current_program_name }
    assert_equal "ERROR: No active program\n", err

    assert @@nxt.start_program("Try-Touch.rtm")
    sleep(1)
    assert_equal "Try-Touch.rtm", @@nxt.get_current_program_name
    assert @@nxt.stop_program
	end
	
	# TODO write tests for the LS methods, since I'm still not sure what they do, 
	# I don't know how to test them
	
	def test_ls_get_status
	end

	def test_ls_write
	end
	
	def test_ls_read
  end
	
	def test_get_firmware_version
    version = @@nxt.get_firmware_version
    assert_kind_of Hash, version
    assert version[:firmware].size > 1
    assert version[:protocol].size > 1
	end
	
	def test_get_device_info
	  info = @@nxt.get_device_info
	  assert_kind_of Hash, info
	  assert info[:name].size > 0
	  assert info[:address].size == 17
	  assert info[:signal].size > 0
	  assert info[:free].size > 0
	end
	
	def test_set_brick_name
	  assert old_name = @@nxt.get_device_info[:name]
	  assert @@nxt.set_brick_name("Foo")
    sleep 1 # brick tends to lock up for a bit after setting the brick name
    assert new_name = @@nxt.get_device_info[:name]
    assert_equal "Foo", new_name

    assert @@nxt.set_brick_name(old_name)
    sleep 1
    assert new_name = @@nxt.get_device_info[:name]
    assert_equal old_name, new_name
	end
	
	def test_find_first
	  assert first_file = @@nxt.find_first
	  assert_kind_of Hash, first_file
	  assert first_file[:handle].size > 0
	  assert first_file[:name].size > 0
	  assert first_file[:size].size > 0
	  assert @@nxt.close_handle(first_file[:handle])

	  assert first_file = @@nxt.find_first("*.rso")
	  assert_kind_of Hash, first_file
	  assert first_file[:handle].size > 0
	  assert first_file[:name].size > 0
	  assert first_file[:size].size > 0
	  assert @@nxt.close_handle(first_file[:handle])
	  
    err = capture_stderr { assert !@@nxt.find_first("*.foo") }
    assert_equal "ERROR: File not found\n", err
	end
	
	def test_close_handle
	  assert file = @@nxt.find_first
	  assert closed = @@nxt.close_handle(file[:handle])
	  assert_equal file[:handle], closed
	  # since we closed the last call, another find_first should use the same handle
	  assert_equal file[:handle], @@nxt.find_first[:handle]
	end
	
	def test_find_next
	  assert file = @@nxt.find_first
	  assert_kind_of Hash, file
	  assert file[:handle].size > 0
	  assert file[:name].size > 0
	  assert file[:size].size > 0
	  assert @@nxt.close_handle(file[:handle])

	  assert next_file = @@nxt.find_next(file[:handle])
	  assert_kind_of Hash, next_file
	  assert next_file[:handle].size > 0
	  assert next_file[:name].size > 0
	  assert next_file[:size].size > 0
	  assert @@nxt.close_handle(next_file[:handle])
	end
	
	def test_open_read
	  assert file = @@nxt.find_first
	  assert read = @@nxt.open_read(file[:name])
	  assert_kind_of Hash, file
	  assert file[:handle].size > 0
	  assert file[:size].size > 0
	  assert @@nxt.close_handle(file[:handle])
	end
	
	def test_open_write
	  assert write = @@nxt.open_write("test.txt")
	  assert_equal 0, write
	  assert @@nxt.close_handle(write)
	  assert @@nxt.delete_file("test.txt")
	end
end
