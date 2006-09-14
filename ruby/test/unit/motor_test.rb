require 'test/unit'
require File.dirname(__FILE__)+'/../../motor'

$DEV = '/dev/tty.NXT-DevB-1'

class MotorTest < Test::Unit::TestCase

	@@nxt = NXTComm.new($DEV)

	def setup
		@motors = []
		@motors << Motor.new(@@nxt, :a)
		@motors << Motor.new(@@nxt, :b)
		@motors << Motor.new(@@nxt, :c)
		
		# make sure that we can talk to each of the motors before we try to run any tests
#		@motors.each do |m|
#			state = m.read_state
#			if not state
#				raise "Cannot run tests because motor #{m.port} is not responding."
#			end
#		end
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
	  	m.reset_tacho
	  	m.forward(:degrees => 360, :power => 10)
	  	state = m.read_state
	  	assert_in_delta(360, state[:rotation_count], 35)
	  	
	  	m.reset_tacho
	  	m.backward(:degrees => 360, :power => 10)
	  	state = m.read_state
	  	assert_in_delta(-360, state[:rotation_count], 35)
  	end
  end
  
  def test_run_by_seconds
  	@motors.each do |m|
	  	m.reset_tacho
	  	m.forward(:time => 3, :power => 15)
	  	state = m.read_state
	  	assert_in_delta(344, state[:rotation_count], 50)
	  	
	  	m.reset_tacho
	  	m.backward(:time => 3, :power => 15)
	  	state = m.read_state
	  	assert_in_delta(-344, state[:rotation_count], 50)
	  end
  end
  

  
end
