require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'ms/mascot/fragment'

class Ms::Mascot::FragmentTest < Test::Unit::TestCase
  acts_as_script_test 
  
  def test_fragment_documentation
    script_test(File.dirname(__FILE__) +  "../../../../") do |cmd|
      cmd.check "documentation", %q{
% rap fragment TVQQEL --+ dump --no-audit
  I[:...:]           fragment TVQQEL
# date: :...:
--- 
ms/mascot/fragment (:...:): 
- - 717.3777467
  - - -717.3777467
    - -699.367182
    - 102.054955
    - 132.1019047
    - 201.123369
    - 261.1444977
    - 329.181947
    - 389.2030757
    - 457.240525
    - 517.2616537
    - 586.283118
    - 616.3300677
}
    end
  end
end