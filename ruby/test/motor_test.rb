require 'test/unit'
require 'motor'

$DEV = '/dev/tty.NXT-DevB-1'

class MotorTest < Test::Unit::TestCase

	def setup
		@motors = []
		@motors << Motor.new('a')
		@motors << Motor.new('b')
		@motors << Motor.new('c')
		
		# make sure that we can talk to each of the motors before we try to run any tests
#		@motors.each do |m|
#			state = m.state
#			if not state
#				raise "Cannot run tests because motor #{m.port} is not responding."
#			end
#		end
	end
	
	def teardown
		@motors.each {|m| m.disconnect}
	end
	
	def test_name
		assert_equal 'a', @motors[0].name
		assert_equal 'b', @motors[1].name
		assert_equal 'c', @motors[2].name
	end
	
	def test_state
		# check just one motor
		state = @motors.first.state
		assert_not_nil state
		assert_equal @motors.first.port, state[:port]
	
		# now do all motors (in parallel, since each should launch its own thread)
		@motors.each do |m|
			state = m.state
			assert_not_nil state
			assert_equal m.port, state[:port]
		end
		
		# run it again to make sure we can do it consecutively
		@motors.each do |m|
			state = m.state
			assert_not_nil state
			assert_equal m.port, state[:port]
		end
		
		# sanity check... two consecutive state checks should be the same, since nothing's changed
		@motors.each do |m|
			state1 = m.state
			state2 = m.state
			assert_equal state1, state2
		end
	end
	
	def test_reset_tacho
		@motors.each do |m|
			m.reset_tacho
			state = m.state
			assert_equal 0, state[:degree_count]
		end
	end
  
  def test_run_by_degrees
  	# we have to use a low power, otherwise we can't get fine tacho control due to inertia
  	
  	@motors.each do |m|
	  	m.reset_tacho
	  	m.forward(:degrees => 360, :power => 10)
	  	state = m.state
	  	assert_in_delta(360, state[:degree_count], 30)
	  	
	  	m.reset_tacho
	  	m.backward(:degrees => 360, :power => 10)
	  	state = m.state
	  	assert_in_delta(-360, state[:degree_count], 30)
  	end
  end
  
  def test_run_by_seconds
  	@motors.each do |m|
	  	m.reset_tacho
	  	m.forward(:time => 3, :power => 15)
	  	state = m.state
	  	assert_in_delta(344, state[:degree_count], 50)
	  	
	  	m.reset_tacho
	  	m.backward(:time => 3, :power => 15)
	  	state = m.state
	  	assert_in_delta(-344, state[:degree_count], 50)
	  end
  end
  

  
end
