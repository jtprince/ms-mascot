require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/mgf/archive'
require 'stringio'

include Ms::Mascot::Mgf

describe Archive do
  
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

  it 'reindex' do
    strio = StringIO.new(MGF_1 + MGF_2)
    begin
      a = Archive.new(strio)
    
      assert_equal 0, a.length
      a.reindex
      assert_equal 2, a.length
    
      assert_equal MGF_1, a[0].to_s
      assert_equal 321.571138, a[0].pepmass
    
      assert_equal MGF_2, a[1].to_s
    ensure
      a.close
    end
  end
  
  it 'str_to_entry' do
    begin
      a = Archive.new
      e = a.str_to_entry(MGF_1)
      
      assert_equal Entry, e.class
      assert_equal 321.571138, e.pepmass
    ensure
      a.close
    end
  end
end
