require File.join(File.dirname(__FILE__), '../../tap_spec_helper.rb') 
require 'ms/mascot/format_mgf'

class Ms::Mascot::FormatMgfSpec < MiniTest::Spec
  acts_as_tap_test 
  
  #
  # describe process
  #
  
  it "must dump the data and headers in mgf format" do
    task = Ms::Mascot::FormatMgf.new
    
    data = [
      102.054955,
      132.101905,
      201.123369,
      261.144498,
      329.181947,
      389.203076,
      457.240525,
      517.261654,
      586.283118,
      616.330068
    ]
    headers = {:parent_ion_mass => 717.377747, :charge => 1, :title => 'TVQQEL (y, b)'}
    
    assert_equal %q{
BEGIN IONS
TITLE=TVQQEL (y, b)
CHARGE=1+
PEPMASS=717.377747
102.054955
132.101905
201.123369
261.144498
329.181947
389.203076
457.240525
517.261654
586.283118
616.330068
END IONS

}, "\n" + task.process(data, headers)
  end
end