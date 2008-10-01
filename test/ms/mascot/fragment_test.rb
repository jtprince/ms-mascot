require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'ms/mascot/fragment'

class Ms::Mascot::FragmentTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  def test_fragment
    task = Ms::Mascot::Fragment.new :message => "goodnight"
    
    # a simple test
    assert_equal({:message  => 'goodnight'}, task.config)
    assert_equal "goodnight moon", task.process("moon")
    
    # a more complex test
    task.enq("moon")
    app.run
    
    assert_equal ["goodnight moon"], app.results(task)
    assert_audit_equal ExpAudit[[nil, "moon"], [task, "goodnight moon"]], app._results(task)[0]
  end
end