require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/mgf/entry'

include Ms::Mascot::Mgf
describe Entry do
  
  # Xcalibur RAW file extracted using raw_to_mgf and abbreviated (7100401blank.RAW)
  MGF_0 = %Q{BEGIN IONS
TITLE=7100401blank.190.190.2.dta
CHARGE=2+
PEPMASS=321.571138
100.266 2.0
111.323 2.5
127.186 14.7
496.110 3.3
601.206 1.3

END IONS}

  #
  # class parse tests 
  #
  
  it 'parse' do
    e = Entry.parse(MGF_0)
    assert_equal 321.571138, e.pepmass
    assert_equal 2, e.charge
    assert_equal({'TITLE' => '7100401blank.190.190.2.dta'}, e.headers)
    assert_equal([
      [100.266, 2.0],
      [111.323, 2.5],
      [127.186, 14.7],
      [496.110, 3.3],
      [601.206, 1.3]
    ], e.data)
  end
    
  it 'parse_raises_error_for_malformed_str' do
    err = lambda { Entry.parse("") }.must_raise(ArgumentError) 
    assert_equal "input should begin with 'BEGIN IONS'", err.message
    
    err = lambda { Entry.parse("BEGIN IONS\n") }.must_raise(ArgumentError) 
    assert_equal "input should end with 'END IONS'", err.message
  end
  
  #
  # initialize tests 
  #

  it 'entry_initialization' do
    e = Entry.new
    assert_equal({}, e.headers)
    assert_equal(nil, e.charge)
    assert_equal(nil, e.pepmass)
    assert_equal([], e.data)
    
    e = Entry.new({'TITLE' => 'name', 'CHARGE' => '1-'}, [[10, 100], [20, 200]])
    assert_equal({'TITLE' => 'name'}, e.headers)
    assert_equal(-1, e.charge)
    assert_equal(nil, e.pepmass)
    assert_equal([[10, 100], [20, 200]], e.data)
  end
  
  #
  # CHARGE get/set
  #
  
  it 'get_charge_using_AREF' do
    e = Entry.new
    e.charge = 1
    assert_equal "1+", e['CHARGE']
    
    e.charge = -1
    assert_equal "1-", e['CHARGE']
  end
  
  it 'set_charge_using_ASET' do
    e = Entry.new
    e['CHARGE'] = "1-"
    assert_equal(-1, e.charge)
    
    e['CHARGE'] = "10-"
    assert_equal(-10, e.charge)
    
    e['CHARGE'] = "1+"
    assert_equal(1, e.charge)
    
    e['CHARGE'] = "10+"
    assert_equal(10, e.charge)
    
    err = lambda { e['CHARGE'] = "" }.must_raise(RuntimeError)
    #err = assert_raise(RuntimeError) { e['CHARGE'] = "" }
    assert_equal "charge should be an number, or a string formatted like '1+' or '1-'", err.message
    
    err = lambda { e['CHARGE'] = "1" }.must_raise(RuntimeError)
    #err = assert_raise(RuntimeError) { e['CHARGE'] = "1" }
    assert_equal "charge should be an number, or a string formatted like '1+' or '1-'", err.message
  end
  
  #
  # PEPMASS get/set
  #
  
  it 'set_pepmass_using_ASET' do
    e = Entry.new
    e['PEPMASS'] = "3.14159"
    assert_equal 3.14159, e.pepmass
  end
  
  it 'get_pepmass_using_AREF' do
    e = Entry.new
    e.pepmass = 3.14159
    assert_equal "3.14159", e['PEPMASS']
  end
  
  #
  # dump tests
  #
  
  it 'dump_on_an_empty_entry' do
    e = Entry.new
    assert_equal(
%Q{BEGIN IONS
CHARGE=
PEPMASS=
END IONS
}, e.dump)
  end

  it 'dump_formats_an_entry_in_mgf_format' do
    e = Entry.new
    e["TITLE"] = "constants"
    e.pepmass = 3.14159
    e.charge = 1
    e.data << [6.02214179, 6.62606896]
    
    assert_equal(
%Q{BEGIN IONS
TITLE=constants
CHARGE=1+
PEPMASS=3.14159
6.02214179 6.62606896
END IONS
}, e.dump)
  end
  
  it 'dump_with_header_options_adds_or_filters_headers' do
    e = Entry.new(:A => 'a', :B => 'b')
    assert_equal(
%Q{BEGIN IONS
A=a
C=
CHARGE=
PEPMASS=
END IONS
}, e.dump("", :headers => ['A', 'C']))
  end
  
  it 'dump_with_mz_and_intensity_precision_options_sets_output_precision_for_data' do
    e = Entry.new({}, [
      [0.1230888, 0.120888],
      [0.1235888, 0.125888],
      [0.1239888, 0.129888]
    ])
    assert_equal(%Q{BEGIN IONS
CHARGE=
PEPMASS=
0.123 0.12
0.124 0.13
0.124 0.13
END IONS
}, e.dump("", :mz_precision => 3, :intensity_precision => 2))
  end
  
  it 'dump_with_pepmass_precision_option_sets_pepmass_preceision' do
    e = Entry.new
    e.pepmass = 0.1230888
    assert_equal(%Q{BEGIN IONS
CHARGE=
PEPMASS=0.123
END IONS
}, e.dump("", :pepmass_precision => 3))

    e.pepmass = 0.1235888
    assert_equal(%Q{BEGIN IONS
CHARGE=
PEPMASS=0.124
END IONS
}, e.dump("", :pepmass_precision => 3))

    e.pepmass = 0.1239888
    assert_equal(%Q{BEGIN IONS
CHARGE=
PEPMASS=0.124
END IONS
}, e.dump("", :pepmass_precision => 3))
  end
  
  class MockTarget
    attr_accessor :str
    def initialize
      @str = ""
    end  
    
    def <<(input)
      @str << input
    end
  end
  
  it 'dump_returns_target' do
    target = MockTarget.new
    assert_equal target, Entry.new.dump(target)
  end
  
  it 'dump_pushes_to_the_target' do
    target = MockTarget.new
    Entry.new.dump(target)
    
    assert_equal(%Q{BEGIN IONS
CHARGE=
PEPMASS=
END IONS
}, target.str)
  end
end
