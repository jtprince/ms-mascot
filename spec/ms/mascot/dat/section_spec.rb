require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/dat/section'

class SectionTest < MiniTest::Spec
  include Ms::Mascot::Dat
  
  # From sample mascot data F981122.dat
  SAMPLE_SECTION = %Q{

Content-Type: application/x-Mascot; name="parameters"

LICENSE=Licensed to: Matrix Science Internal use only - Frill, (4 processors).
MP=
NM=
COM=Peptide Mass Fingerprint Example
IATOL=
}

  it 'parses and returns new instance' do
    p = Section.parse(SAMPLE_SECTION)
    p.data.must_equal({
      'LICENSE' => 'Licensed to: Matrix Science Internal use only - Frill, (4 processors).',
      'MP' => '',
      'NM' => '',
      'COM' => 'Peptide Mass Fingerprint Example',
      'IATOL' => ''
    })
  end

  # Put together from several dat files/sections all with the
  # parameters format.
  MISHMASH_SECTION = %Q{

Content-Type: application/x-Mascot; name="parameters"

LICENSE=Licensed to: Matrix Science Internal use only - Frill, (4 processors).
IATOL=
A=71.037114
B=114.534940
sequences=257964
sequences_after_tax=257964
qmass18=2881.492724
qexp18=2882.500000,1+
h1_q7_terms=R,A
h1_q8=-1
h12_q16=1,2549.414505,-0.121781,2,23,0.00,RIDIITIFPDYFTPLDLSLIGK,0,000000000000000000000000,0.00,1,0000000000000000000,0,0,0.000000
q1_p1=0,1980.854843,79.930605,0,FQSEEQQQTEDELQDK,0,000000000000000000,78.09,0000000000000000000,0,0;"CASB_BOVIN":0:48:63:0,"CASB_CAPHI":0:48:63:0,"CASB_SHEEP":0:48:63:0
q1_p1_terms=K,I:K,I:K,I
"CASB_SHEEP"=24859.19,"Beta-casein precursor - Ovis aries (Sheep)"
"CASB_CAPHI"=24849.17,"Beta-casein precursor - Capra hircus (Goat)"
}

  it 'correctly parses a variety of parameters' do
    p = Section.parse(MISHMASH_SECTION)
    p.data.must_equal({
      "LICENSE" => "Licensed to: Matrix Science Internal use only - Frill, (4 processors).",
      "IATOL" => "",
      "A" => "71.037114",
      "B" => "114.534940",
      "sequences" => "257964",
      "sequences_after_tax" => "257964",
      "qmass18" => "2881.492724",
      "qexp18" => "2882.500000,1+",
      "h1_q7_terms" => "R,A",
      "h1_q8" => "-1",
      "h12_q16" => "1,2549.414505,-0.121781,2,23,0.00,RIDIITIFPDYFTPLDLSLIGK,0,000000000000000000000000,0.00,1,0000000000000000000,0,0,0.000000",
      "q1_p1" => "0,1980.854843,79.930605,0,FQSEEQQQTEDELQDK,0,000000000000000000,78.09,0000000000000000000,0,0;\"CASB_BOVIN\":0:48:63:0,\"CASB_CAPHI\":0:48:63:0,\"CASB_SHEEP\":0:48:63:0",
      "q1_p1_terms" => "K,I:K,I:K,I",
      "\"CASB_SHEEP\"" => "24859.19,\"Beta-casein precursor - Ovis aries (Sheep)\"",
      "\"CASB_CAPHI\"" => "24849.17,\"Beta-casein precursor - Capra hircus (Goat)\""
    })
  end

  it 'formats parameters with content type header on to_s' do
    p = Section.new('key' => 'value')
    p.to_s.must_equal %Q{

Content-Type: application/x-Mascot; name="section"

key=value
}
  end

end


# some tests on the section name
class ClassSectionNameSpec < MiniTest::Spec
  include Ms::Mascot::Dat

  it 'gives downcased name' do
    Ms::Mascot::Dat::Section.section_name.must_equal "section"
  end

  class Subclass < Section
  end

  it 'gives downcased unnested constant name for subclasses' do
    Subclass.section_name.must_equal "subclass"
  end

  it 'section name is class section name' do
    Ms::Mascot::Dat::Section.new.section_name.must_equal "section"
    Subclass.new.section_name.must_equal "subclass"
  end

end
