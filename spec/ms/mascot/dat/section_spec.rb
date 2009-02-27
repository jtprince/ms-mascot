require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/dat/section'

class SectionSpec < MiniTest::Spec
  include Ms::Mascot::Dat
  
  #
  # describe Section#parse
  #
  
  # From sample mascot data F981122.dat
  SAMPLE_SECTION = %Q{

Content-Type: application/x-Mascot; name="parameters"

LICENSE=Licensed to: Matrix Science Internal use only - Frill, (4 processors).
MP=
NM=
COM=Peptide Mass Fingerprint Example
IATOL=
}

  it 'must parse and returns new instance' do
    p = Section.parse(SAMPLE_SECTION)
    p.data.must_equal({
      'LICENSE' => 'Licensed to: Matrix Science Internal use only - Frill, (4 processors).',
      'MP' => '',
      'NM' => '',
      'COM' => 'Peptide Mass Fingerprint Example',
      'IATOL' => ''
    })
  end

  # Put together from several dat files/sections all with the parameters format.
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

  it 'must correctly parse a variety of parameters' do
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
  
  #
  # describe Section#name
  #
  
  class Subclass < Section
  end
  
  it 'must give the downcased, unnested constant name' do
    Section.section_name.must_equal "section"
    Subclass.section_name.must_equal "subclass"
  end
  
  #
  # describe Section.name
  #
  
  it 'must equal the class section name' do
    Ms::Mascot::Dat::Section.new.section_name.must_equal "section"
    Subclass.new.section_name.must_equal "subclass"
  end
  
  #
  # describe Section.to_s
  #

  it 'must format parameters with content type header' do
    p = Section.new('key' => 'value')
    p.to_s.must_equal %Q{

Content-Type: application/x-Mascot; name="section"

key=value
}
  end
end
