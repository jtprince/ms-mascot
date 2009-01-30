require File.join(File.dirname(__FILE__), '../../../tap_test_helper.rb') 
require 'ms/mascot/dat/section'

class SectionTest < Test::Unit::TestCase
  include Ms::Mascot::Dat
  
  #
  # parse test
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

  def test_parse_parses_and_returns_new_instance
    p = Section.parse(SAMPLE_SECTION)
    assert_equal({
      'LICENSE' => 'Licensed to: Matrix Science Internal use only - Frill, (4 processors).',
      'MP' => '',
      'NM' => '',
      'COM' => 'Peptide Mass Fingerprint Example',
      'IATOL' => ''
    }, p.data)
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

  def test_parse_correctly_parses_a_variety_of_parameters
    p = Section.parse(MISHMASH_SECTION)
    assert_equal({
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
    }, p.data)
  end
  
  #
  # Section.section_name test
  #
  
  def test_class_section_name_documentation
    assert_equal "section", Ms::Mascot::Dat::Section.section_name
  end
  
  class Subclass < Section
  end
  
  def test_class_section_name_is_downcased_unnested_constant_name
    assert_equal "subclass", Subclass.section_name
  end
  
  #
  # section_name test
  #
  
  def test_section_name_is_class_section_name
    assert_equal "section", Ms::Mascot::Dat::Section.new.section_name
    assert_equal "subclass", Subclass.new.section_name
  end
  
  #
  # to_s test
  #
  
  def test_to_s_formats_parameters_with_content_type_header
    p = Section.new('key' => 'value')
    assert_equal %Q{

Content-Type: application/x-Mascot; name="section"

key=value
}, p.to_s
  end
end
