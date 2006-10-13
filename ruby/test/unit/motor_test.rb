require File.dirname(__FILE__) + '/../test_helper'
require "test/unit"
require "motor"
require "autodetect_nxt"

class MotorTest < Test::Unit::TestCase

  @@nxt = NXTComm.new($DEV)
  
  puts "\nWARNING: The battery level is low. Test results may be inconsistent.\n" if @@nxt.get_battery_level < 6040

  def setup
    @motors = []
    @motors << Motor.new(@@nxt, :a)
    @motors << Motor.new(@@nxt, :b)
    @motors << Motor.new(@@nxt, :c)
        
    # make sure that we can talk to each of the motors before we try to run any tests
#    @motors.each do |m|
#      state = m.read_state
#      if not state
#        raise "Cannot run tests because motor #{m.port} is not responding."
#      end
#    end
  end
  
  def teardown
  end
  
  def test_name
    assert_equal 'a', @motors[0].name
    assert_equal 'b', @motors[1].name
    assert_equal 'c', @motors[2].name
  end
  
  def test_read_state
    # check just one motor
    state = @motors.first.read_state
    assert_not_nil state
    assert_equal @motors.first.port, state[:port]
  
    # now do all motors
    @motors.each do |m|
      state = m.read_state
      assert_not_nil state
      assert_equal m.port, state[:port]
    end
    
    # sanity check... two consecutive state checks should be the same, since nothing's changed
    @motors.each do |m|
      state1 = m.read_state
      state2 = m.read_state
      assert_equal state1, state2
    end
  end
  
  def test_reset_tacho
    @motors.each do |m|
      m.reset_tacho
      state = m.read_state
      assert_equal 0, state[:rotation_count]
    end
  end
  
  def test_run_by_degrees
    # we have to use a low power, otherwise we can't get fine tacho control due to inertia
    
    @motors.each do |m|
    	m.stop
    
      m.reset_tacho
      m.forward(:degrees => 180, :power => 5)
      state = m.read_state
      assert_in_delta(180, state[:rotation_count], 40)
      
      m.stop
      
      m.reset_tacho
      m.backward(:degrees => 180, :power => 5)
      state = m.read_state
      assert_in_delta(-180, state[:rotation_count], 40)
      
      m.stop
    end
  end
  
  def test_run_by_seconds
  	# only need to test one motor, since we already tested tacho for all motors in test_run_by_degrees
    m = @motors.first
    
	  m.reset_tacho
	  m.forward(:time => 3, :power => 15)
	  state = m.read_state
	  assert_in_delta(450, state[:rotation_count], 100)
	  
	  m.reset_tacho
	  m.backward(:time => 3, :power => 15)
	  state = m.read_state
	  assert_in_delta(-450, state[:rotation_count], 100)
  end
  
  def test_run_free
  	m = @motors.first
  	m.reset_tacho
  	m.forward(:power => 15)
  	sleep(3)
  	m.stop
  	assert_in_delta(450, m.read_state[:rotation_count], 100)
  	
  	# now see what happens when we interrupt the movement
  	m.reset_tacho
  	m.forward(:power => 15)
  	sleep(1)
  	m.backward(:power => 15)
  	sleep(1)
  	m.stop
  	assert_in_delta(0, m.read_state[:rotation_count], 35)
  end
  
#  def test_tiny_slow_movements
#  	# it seems to help if we stop for a bit first
#  	sleep(1)
#  
#  	m = @motors.first
#  	
#  	m.reset_tacho
#  	m.forward(:degrees => 10, :power => 1)
#  	state = m.read_state
#  	assert_in_delta(10, state[:rotation_count], 2)
#  
#  	m.reset_tacho
#  	m.backward(:degrees => 5, :power => 1)
#  	state = m.read_state
#  	assert_in_delta(-5, state[:rotation_count], 2)
#  	
#  	m.reset_tacho
#  	m.forward(:degrees => 5, :power => 1)
#  	state = m.read_state
#  	assert_in_delta(5, state[:rotation_count], 2)
#
#  	m.reset_tacho
#  	m.backward(:degrees => 15, :power => 1)
#  	state = m.read_state
#  	assert_in_delta(-15, state[:rotation_count], 2)
#
#  	
#  	# Moving by 1 degree pretty much never works :(
#  	#m.reset_tacho
#  	#m.forward(:degrees => 1, :power => 1)
#  	#state = m.read_state
#  	#assert_equal 1, state[:rotation_count]
#  end
  
# This just doesn't work :(
#  def test_tiny_fast_movements
#  	m = @motors.first
#  	
#  	m.reset_tacho
#  	m.forward(:degrees => 10, :power => 100)
#  	state = m.read_state
#  	assert_in_delta(10, state[:rotation_count], 3)
#  
#  	m.reset_tacho
#  	m.backward(:degrees => 5, :power => 100)
#  	state = m.read_state
#  	assert_in_delta(-5, state[:rotation_count], 3)
#  	
#  	# Moving by 1 degree pretty much never works :(
#  	#m.reset_tacho
#  	#m.forward(:degrees => 1, :power => 1)
#  	#state = m.read_state
#  	#assert_equal 1, state[:rotation_count]
#  end
  

  
end
