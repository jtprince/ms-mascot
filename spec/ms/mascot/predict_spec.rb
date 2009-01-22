require File.join(File.dirname(__FILE__), '../../tap_spec_helper.rb') 
require 'ms/mascot/predict'


describe Ms::Mascot::Predict do
  acts_as_script_test
  acts_as_file_test
  
  def test_predict_documentation
    script_test(File.dirname(__FILE__) +  "../../../../") do |cmd|
      target = method_root.filepath(:output, 'target.mgf')
      
      cmd.check "documentation", %Q{
% rap predict MAEELVLERCDLELETNGRDHHTADLCREKLVVRRGQPFWLTLHFEGRNYEASVDSLTFS "#{target}"
  I[:...:]             digest MAEELVLERCD... to 15 peptides
  I[:...:]           fragment MAEELVLER
  I[:...:]           fragment MAEELVLERCDLELETNGR
  I[:...:]           fragment CDLELETNGR
  I[:...:]           fragment CDLELETNGRDHHTADLCR
  I[:...:]           fragment DHHTADLCR
  I[:...:]           fragment DHHTADLCREK
  I[:...:]           fragment EKLVVR
  I[:...:]           fragment LVVR
  I[:...:]           fragment LVVRR
  I[:...:]           fragment RGQPFWLTLHFEGR
  I[:...:]           fragment GQPFWLTLHFEGR
  I[:...:]           fragment GQPFWLTLHFEGRNYEASVDSLTFS
  I[:...:]           fragment NYEASVDSLTFS}
  
      assert_files { [target] }
    end
  end
end
