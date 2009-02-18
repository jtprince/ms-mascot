require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/mgf/entry'

class MgfEntrySpec < MiniTest::Spec
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
  # describe Entry#parse
  #
  
  it 'must parse an mgf entry string' do
    e = Entry.parse(MGF_0)
    e.pepmass.must_equal 321.571138
    e.charge.must_equal 2
    e.headers.must_equal 'TITLE' => '7100401blank.190.190.2.dta'
    e.data.must_equal [
      [100.266, 2.0],
      [111.323, 2.5],
      [127.186, 14.7],
      [496.110, 3.3],
      [601.206, 1.3]
    ]
  end
    
  it 'must raises an error for a malformed entry string' do
    err = lambda { Entry.parse("") }.must_raise(ArgumentError) 
    assert_equal "input should begin with 'BEGIN IONS'", err.message
    
    err = lambda { Entry.parse("BEGIN IONS\n") }.must_raise(ArgumentError) 
    assert_equal "input should end with 'END IONS'", err.message
  end
  
  #
  # describe Entry#new 
  #

  it 'must initialize a default entry' do
    e = Entry.new
    e.headers.must_equal({})
    e.charge.must_equal nil
    e.pepmass.must_equal nil
    e.data.must_equal []
  end
  
  it 'must accept a headers hash and data array' do
    e = Entry.new({'TITLE' => 'name', 'CHARGE' => '1-'}, [[10, 100], [20, 200]])
    e.headers.must_equal({'TITLE' => 'name'})
    e.charge.must_equal(-1)
    e.pepmass.must_equal nil
    e.data.must_equal [[10, 100], [20, 200]]
  end
  
  #
  # describe Entry.charge
  #
  
  it 'must set Entry["CHARGE"]' do
    e = Entry.new
    e.charge = 1
    e['CHARGE'].must_equal "1+"
    
    e.charge = -1
    e['CHARGE'].must_equal "1-"
  end
  
  it 'must be set by Entry["CHARGE"]' do
    e = Entry.new
    e['CHARGE'] = "1-"
    e.charge.must_equal(-1)
    
    e['CHARGE'] = "10-"
    e.charge.must_equal(-10)
    
    e['CHARGE'] = "1+"
    e.charge.must_equal 1
    
    e['CHARGE'] = "10+"
    e.charge.must_equal 10
    
    err = lambda { e['CHARGE'] = "" }.must_raise(RuntimeError)
    err.message.must_equal "charge should be an number, or a string formatted like '1+' or '1-'"
    
    err = lambda { e['CHARGE'] = "1" }.must_raise(RuntimeError)
    err.message.must_equal "charge should be an number, or a string formatted like '1+' or '1-'"
  end
  
  #
  # describe Entry.pepmass
  #
  
  it 'must set Entry["PEPMASS"]' do
    e = Entry.new
    e.pepmass = 3.14159
    e['PEPMASS'].must_equal "3.14159"
  end
  
  it 'must be set by Entry["PEPMASS"]' do
    e = Entry.new
    e['PEPMASS'] = "3.14159"
    e.pepmass.must_equal 3.14159
  end
  
  #
  # describe Entry.dump
  #
  
  it 'must work for an empty entry' do
    e = Entry.new
     %Q{
BEGIN IONS
CHARGE=
PEPMASS=
END IONS
}
  end

  it 'must recreate mgf format' do
    e = Entry.new
    e["TITLE"] = "constants"
    e.pepmass = 3.14159
    e.charge = 1
    e.data << [6.02214179, 6.62606896]
    
    ("\n" + e.dump).must_equal %Q{
BEGIN IONS
TITLE=constants
CHARGE=1+
PEPMASS=3.14159
6.02214179 6.62606896
END IONS
}
  end
  
  it 'must filter headers by headers option' do
    e = Entry.new(:A => 'a', :B => 'b')
    dump = e.dump("", :headers => ['A', 'C'])
    ("\n" + dump).must_equal %Q{
BEGIN IONS
A=a
C=
CHARGE=
PEPMASS=
END IONS
}
  end
  
  it 'must output the specified mz and intensity precision' do
    e = Entry.new({}, [
      [0.1230888, 0.120888],
      [0.1235888, 0.125888],
      [0.1239888, 0.129888]
    ])
    
    dump = e.dump("", :mz_precision => 3, :intensity_precision => 2)
    ("\n" + dump).must_equal %Q{
BEGIN IONS
CHARGE=
PEPMASS=
0.123 0.12
0.124 0.13
0.124 0.13
END IONS
}
  end
  
  it 'must output pepmass with the specified pepmass precision' do
    e = Entry.new
    e.pepmass = 0.1230888
    
    dump = e.dump("", :pepmass_precision => 3)
    ("\n" + dump).must_equal %Q{
BEGIN IONS
CHARGE=
PEPMASS=0.123
END IONS
}

    e.pepmass = 0.1235888
    dump = e.dump("", :pepmass_precision => 3)
    ("\n" + dump).must_equal %Q{
BEGIN IONS
CHARGE=
PEPMASS=0.124
END IONS
}

    e.pepmass = 0.1239888
    dump = e.dump("", :pepmass_precision => 3)
    ("\n" + dump).must_equal %Q{
BEGIN IONS
CHARGE=
PEPMASS=0.124
END IONS
}
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
  
  it 'must return target' do
    target = MockTarget.new
    Entry.new.dump(target).must_equal target
  end
  
  it 'must dump to target' do
    target = MockTarget.new
    Entry.new.dump(target)
    
    ("\n" + target.str).must_equal %Q{
BEGIN IONS
CHARGE=
PEPMASS=
END IONS
}
  end
end
