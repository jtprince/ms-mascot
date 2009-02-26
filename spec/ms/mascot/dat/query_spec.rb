require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/dat/query'

class QuerySpec < MiniTest::Spec
  include Ms::Mascot::Dat
  
  # An abbreviated query section from F981122.dat
  SAMPLE_QUERY = %Q{
Content-Type: application/x-Mascot; name="query60"

charge=3+
mass_min=50.175000
mass_max=1998.960000
int_min=0.0364
int_max=7366
num_vals=3411
num_used1=-1
Ions1=129.098825:384.8,187.070000:461.5,289.150000:1019,402.239654:2017
}
  
  attr_reader :query
  
  before do
    @query = Query.parse SAMPLE_QUERY
  end
  
  #
  # describe Query#scan_ions
  #
  
  it "satisfies Query#scan_ions documentation" do
    str = "\nReformatted Ions\n"
    Query.scan_ions('1.23:4.56,7.8:9') do |num, end_point|
      str << num
      str << (end_point ? "\n" : " ")
    end
  
    str.must_equal %q{
Reformatted Ions
1.23 4.56
7.8 9
}
  end
  
  it "yields each number string and an end_point flag to the block" do
    str = "129.098825:384.8,187.070000:461.5,289.150000:1019,402.239654:2017"
    
    results = []
    Query.scan_ions(str) do |num, next_char|
      results << [num, next_char]
    end
    
    results.must_equal [
      ["129.098825", false],
      ["384.8", true],
      ["187.070000", false],
      ["461.5", true],
      ["289.150000", false],
      ["1019", true],
      ["402.239654", false],
      ["2017", true]
    ]
  end
  
  #
  # describe Query.parse_ions
  #
  
  it "satisfies Query#parse_ions documentation" do
    Query.parse_ions('1.23:4.56,7.8:9').must_equal [[1.23, 4.56], [7.8, 9]]
  end
  
  #
  # describe ion_str
  #
  
  it "returns the first ion string" do
    query.ion_str.must_equal "129.098825:384.8,187.070000:461.5,289.150000:1019,402.239654:2017"
  end
  
  #
  # describe ions
  #
  
  it "returns the first ion string parsed into a simple array" do
    query.ions.must_equal [
      [129.098825, 384.8],
      [187.070000, 461.5],
      [289.150000, 1019],
      [402.239654, 2017]
    ]
  end
  
  #
  # describe scan_ions
  #
  
  it "scans the first ion string like Query.scan_ions" do
    results = []
    query.scan_ions do |num, next_char|
      results << [num, next_char]
    end
    
    results.must_equal [
      ["129.098825", false],
      ["384.8", true],
      ["187.070000", false],
      ["461.5", true],
      ["289.150000", false],
      ["1019", true],
      ["402.239654", false],
      ["2017", true]
    ]
  end
end