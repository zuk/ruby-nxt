require File.dirname(__FILE__) + '/../test_helper'
require "test/unit"
require "nxt"
require "autodetect_nxt"

class NXTTest < Test::Unit::TestCase

  def setup
    @nxt = NXT.new
  end
  
  def teardown
    @nxt.disconnect
  end
  
  def test_motors_individual
    @nxt.motor_a do |m|
      m.reset_tacho
      m.forward(:degrees => 90, :power => 8)
      
      # FIXME: 35 is a pretty big margin of error... not sure why but sometimes the tests
      #        come in at over 30... maybe there is a problem with the scheduling of the state poll?
      #        the problem doesn't seem to be as bad when we run motor_test.rb...
      assert_in_delta(90, m.read_state[:rotation_count], 35)
    end
    
    @nxt.motor_b do |m|
      m.reset_tacho
      m.forward(:degrees => 90, :power => 8)
      assert_in_delta(90, m.read_state[:rotation_count], 35)
    end
    
    @nxt.motor_c do |m|
      m.reset_tacho
      m.forward(:degrees => 90, :power => 8)
      assert_in_delta(90, m.read_state[:rotation_count], 35)
    end
  end
  
#  def test_motors_multiple
#    @nxt.motors_abc do |m|
#      m.reset_tacho
#    end
#  
#    @nxt.motors_abc do |m|
#      m.forward(:degrees => 360, :power => 10)
#    end
#    
#    @nxt.motors_abc do |m|
#      assert_in_delta(360, m.read_state[:rotation_count], 30)
#    end
#  end
#  
#  def test_sensors
#  	@nxt.sensor_1 do |s|
#  		
#  	end
#  end
  
end
