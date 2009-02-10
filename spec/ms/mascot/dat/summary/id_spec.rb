require File.join(File.dirname(__FILE__), '../../../../tap_spec_helper.rb')
require 'ms/mascot/dat/summary/id'

class IdWithDatFile < MiniTest::Spec
  include Ms::Mascot::Dat

  it 'peptide can be set from Dat string' do
    pep = Summary::Id::Peptide.from_strs('0,936.455246,0.001202,53,61,4.00,GYASPDLSK,16,00000000000,22.56,1,0002001000000000000,0,0,1671.400000', 'R,L')
    hash = {
      :calc_mr => '936.455246',
      :delta => '0.001202',
      :start => '53',
      :end => '61',
      :num_match => '4.00',
      :seq => 'GYASPDLSK',
      :res_before => 'R',
      :res_after => 'L',
    }
    
  end
  
end


class IdUnitSpec < MiniTest::Spec


end
