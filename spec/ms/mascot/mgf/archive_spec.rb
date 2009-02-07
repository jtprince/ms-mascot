require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/mgf/archive'
require 'stringio'

class MgfArchiveSpec < MiniTest::Spec
  include Ms::Mascot::Mgf
  
  MGF_1 = %Q{BEGIN IONS
TITLE=one
CHARGE=2+
PEPMASS=321.571138
100.266 2.0
END IONS
}
  
  MGF_2 = %Q{BEGIN IONS
TITLE=two
KEY=value
CHARGE=1+
PEPMASS=3.1416
6.022 6.63
END IONS
}

  #
  # describe reindex
  #
  
  it 'must index each mgf entry in io' do
    io = StringIO.new(MGF_1 + MGF_2)
    begin
      a = Archive.new(io)
    
      a.length.must_equal 0
      a.reindex
      a.length.must_equal 2 
    
      a[0].to_s.must_equal MGF_1
      a[0].pepmass.must_equal 321.571138
    
      a[1].to_s.must_equal MGF_2
    ensure
      a.close
    end
  end
  
  #
  # describe str_to_entry
  #
  
  it 'must convert an mgf string into an Entry' do
    begin
      a = Archive.new
      e = a.str_to_entry(MGF_1)
      
      e.class.must_equal Entry
      e.pepmass.must_equal 321.571138
    ensure
      a.close
    end
  end
end
