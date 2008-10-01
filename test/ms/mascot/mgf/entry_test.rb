require File.join(File.dirname(__FILE__), '../../../tap_test_helper.rb') 
require 'ms/mascot/mgf/entry'

class MgfEntryTest < Test::Unit::TestCase
  include Ms::Mascot::Mgf
  
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
  
  def test_parse
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
    
  def test_parse_raises_error_for_malformed_str
    assert_raise(Ms::Format::FormatError) { Entry.parse("") }
    assert_raise(Ms::Format::FormatError) { Entry.parse("TITLE=7100401blank.190.190.2.dta\nCHARGE=2+\nPEPMASS=321.571138\n100.266 2.0") }
  end
  
  #
  # initialize tests 
  #

  def test_entry_initialization
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
  
  def test_get_charge_using_AREF
    e = Entry.new
    e.charge = 1
    assert_equal "1+", e['CHARGE']
    
    e.charge = -1
    assert_equal "1-", e['CHARGE']
  end
  
  def test_set_charge_using_ASET
    e = Entry.new
    e['CHARGE'] = "1-"
    assert_equal(-1, e.charge)
    
    e['CHARGE'] = "10-"
    assert_equal(-10, e.charge)
    
    e['CHARGE'] = "1+"
    assert_equal(1, e.charge)
    
    e['CHARGE'] = "10+"
    assert_equal(10, e.charge)
    
    assert_raise(Ms::Format::FormatError) { e['CHARGE'] = "" }
    assert_raise(Ms::Format::FormatError) { e['CHARGE'] = "1" }
  end
  
  #
  # PEPMASS get/set
  #
  
  def test_set_pepmass_using_ASET
    e = Entry.new
    e['PEPMASS'] = "3.14159"
    assert_equal 3.14159, e.pepmass
  end
  
  def test_get_pepmass_using_AREF
    e = Entry.new
    e.pepmass = 3.14159
    assert_equal "3.14159", e['PEPMASS']
  end
  
  #
  # puts tests
  #
  
  def test_puts
    e = Entry.new
    assert_equal(%Q{BEGIN IONS
CHARGE=
PEPMASS=
END IONS
}, e.puts)

    e["TITLE"] = "constants"
    e.pepmass = 3.14159
    e.charge = 1
    e.data << [6.02214179, 6.62606896]
    
    assert_equal(%Q{BEGIN IONS
TITLE=constants
CHARGE=1+
PEPMASS=3.14159
6.02214179 6.62606896
END IONS
}, e.puts)

    assert_equal(%Q{BEGIN IONS
TITLE=constants
ANOTHER=
CHARGE=1+
PEPMASS=3.1416
6.022 6.63
END IONS
}, e.puts("", 
    :mz_precision => 3, 
    :intensity_precision => 2, 
    :pepmass_precision => 4, 
    :headers => ['TITLE', 'ANOTHER']))
  end

  def test_puts_to_a_target
    str = "existing content\n"
    e = Entry.new
    assert_equal str.object_id, e.puts(str).object_id
    
    assert_equal(%Q{existing content
BEGIN IONS
CHARGE=
PEPMASS=
END IONS
}, str)
  end
end
