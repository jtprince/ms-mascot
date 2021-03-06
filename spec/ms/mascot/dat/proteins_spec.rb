require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/dat/proteins'

class ProteinsSpec < MiniTest::Spec
  
  # From sample mascot data F981122.dat
  SAMPLE_PROTEINS = %Q{"ZN711_HUMAN"=87153.77,"Zinc finger protein 711 (Zinc finger protein 6) - Homo sapiens (Human)"
"Y986_MYCTU"=27356.31,"Hypothetical ABC transporter ATP-binding protein Rv0986/MT1014 - Mycobacterium tuberculosis"
"Y5G0_ENCCU"=33509.30,"Hypothetical protein ECU05_1600/ECU11_0130 - Encephalitozoon cuniculi"
}
  
  attr_reader :proteins
  
  before do
    @proteins = Ms::Mascot::Dat::Proteins.parse SAMPLE_PROTEINS
  end
  
  #
  # describe Proteins.parse
  #
  
  it "parses data while removing quotes from keys" do
    proteins = Ms::Mascot::Dat::Proteins.parse SAMPLE_PROTEINS
    proteins.data.keys.sort.must_equal ['Y5G0_ENCCU', 'Y986_MYCTU', 'ZN711_HUMAN']
  end
  
  #
  # describe protein
  #
  
  it "returns a Protein for the specifed id" do
    protein = proteins.protein('Y986_MYCTU')
    protein.mass.must_equal 27356.31
    protein.description.must_equal "Hypothetical ABC transporter ATP-binding protein Rv0986/MT1014 - Mycobacterium tuberculosis"
  end
  
  #
  # describe to_s
  #
  
  it "properly formats proteins section data" do
    proteins.to_s.must_match %r{"ZN711_HUMAN"=87153.77}
  end
end
