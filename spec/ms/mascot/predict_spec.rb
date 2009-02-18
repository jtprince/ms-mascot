require File.join(File.dirname(__FILE__), '../../tap_spec_helper.rb') 
require 'ms/mascot/predict'

class PredictSpec < MiniTest::Spec
  acts_as_tap_test
  include Ms::Mascot
  
  attr_accessor :predict
  
  before do
    super
    @predict = Predict.new
  end
  
  #
  # describe process
  #
  
  it "digests and fragments the sequence and returns the mgf" do
    with_config :quiet => true do
      result = predict.process('MAEELVLERCDLELETNGRDHHTADLCREKLVVRRGQPFWLTLHFEGRNYEASVDSLTFS')
      result.must_equal File.read(ctr['target.mgf'])
    end
  end
end
