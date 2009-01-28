require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/dat/query'

include Ms::Mascot

describe Dat::Query do
  before do
    @string =<<END
title=JP_PM3_0113_10ul_orb1%2e5369%2e5369%2e1%2edta
charge=1+
mass_min=109.230000
mass_max=360.120000
int_min=1
int_max=135.3
num_vals=130
num_used1=-1
Ions1=121.060000:7.9,285.090000:23.9,343.050000:135.3,171.140000:7.8,236.870000:21.1,342.390000:87.3,172.980000:6.6,306.180000:20.7,333.000000:42.8,198.970000:5.2,268.940000:20.2,315.100000:36.8,185.240000:4.6,272.920000:20.2,319.900000:29.4,205.920000:4.5,303.180000:16.3,317.100000:28.2,118.740000:3.7,293.340000:16,332.260000:21.1,199.820000:3.1,263.100000:15.5,324.120000:20.4,206.890000:3.1,233.090000:15.4,343.950000:20,147.060000:3,290.800000:13.4,325.160000:17.9,109.230000:2,128.920000:1.5,131.070000:1.6,131.780000:1.7,137.140000:2.1,145.190000:1.7,150.990000:2.8,152.070000:2.1,154.950000:2.5,160.980000:1.7,161.890000:1.1,162.850000:2,169.030000:1.2,170.140000:2.1,180.020000:1,186.950000:1.3,187.950000:1.1,189.110000:1.1,190.040000:2,196.180000:2.9,200.960000:1.5,202.890000:1.1,205.190000:2.2,209.030000:2.6,211.130000:6.3,212.980000:3.8,214.130000:1.6,215.200000:6.2,216.110000:2.7,217.110000:6.2,217.960000:2.2,218.940000:3.2,220.100000:1.4,223.160000:10,225.070000:5.2,227.140000:3.1,231.490000:4.5,232.190000:4.2,234.160000:5.4,234.950000:5.1,235.910000:12.2,240.160000:5.4,241.090000:7.9,242.960000:3.2,244.160000:1.1,245.260000:1.3,246.810000:9,247.940000:2.2,251.090000:8.8,252.220000:4.9,252.940000:1.2,257.130000:5.7,258.040000:4.4,259.220000:9.9,260.920000:12.5,262.080000:8.1,265.140000:3.2,266.000000:4.7,268.180000:8.4,270.230000:7.1,271.150000:8.3,275.420000:3.9,277.020000:3.3,279.010000:3.5,281.060000:2.6,282.260000:4.2,286.260000:10.2,287.040000:5.2,288.340000:5.4,289.170000:8.4,292.220000:13,294.120000:4,295.200000:1.3,297.230000:6.6,298.480000:7.5,299.280000:10.9,300.060000:4.5,301.210000:8.5,302.080000:12.8,304.270000:12.2,305.090000:13,307.070000:6.2,310.030000:7.5,312.040000:9.4,313.920000:11.6,316.090000:6.7,318.040000:8.5,319.040000:13.1,326.000000:2,327.960000:4.8,328.870000:16.6,329.580000:1.2,331.120000:9.8,334.340000:8,338.770000:5.5,341.160000:3.3,344.970000:5.1,346.020000:5.9,351.250000:10.4,360.120000:19.2
END

  end

  it 'can read and properly cast values of a query' do
    qr = Dat::Query.from_string( @string )
    {:title => "JP_PM3_0113_10ul_orb1.5369.5369.1.dta", :charge => 1, :mass_min => 109.230000, :mass_max => 360.12000, :int_min => 1.0, :int_max=> 135.3, :num_vals => 130, :num_used1=>-1}.each do |k,v|
      qr.send(k).must_equal v
    end
    qr.ions1[0].must_equal [121.06, 7.9]
    qr.ions1[-1].must_equal [360.12, 19.2]
    # alias for ions1
    qr.ions1.must_equal qr.ions
    qr.ions1.must_equal qr.Ions1
  end

end