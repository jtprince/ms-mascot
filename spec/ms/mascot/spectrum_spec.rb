require File.join(File.dirname(__FILE__), '../../tap_spec_helper.rb') 
require 'ms/mascot/spectrum'
require 'ms/mascot'

#
# NOTE:
# Tabs should NOT be replaced with spaces in this test...
# mascot_series uses tabs to split a result string into
# an expected series.
#

# don't like including this in the main object space, but it doesn't work
# inside the describe!
include Ms::Mascot

describe Ms::Mascot do
  # @TODO: for some reason the include doesn't really work for minitest/spec

  def assert_series_equal(series, expected, frag, delta_mass)
    a = expected[series]
    b = frag.series(series)
    
    assert_equal a.length, b.length
    begin
      0.upto(a.length-1) do |index|
        if a[index] == nil
          assert b[index] < 0
        else
          assert_in_delta a[index], b[index], delta_mass
        end
      end
    rescue
      assert_equal a, b, series
    end
  end
  
  def mascot_series(str)
    lines = str.split(/\n/)
    rows = lines.collect do |line|
      next if line.empty? 
      line.split(/\t/)
    end
    columns = rows.compact.transpose

    series ={}
    columns.each do |column|
      key = column.shift
      next if key =~ /#|Seq/
      
      series[key.strip] = column.collect do |ion| 
        ion = ion.strip
        ion.empty? ? nil : ion.to_f
      end
    end
    series
  end

  def identifiers
    ['b', 'b++',  'y', 'y++',  'y*', 'y*++']
  end
  
  it 'fragments_vs_mascot_APGFGDNR' do
    series = mascot_series %Q{
#  	b  	b++  	b*  	b*++  	b0  	b0++  	Seq.  	y  	y++  	y*  	y*++  	y0  	y0++  	#
1 	72.04 	36.53 	  	  	  	  	A 	  	  	  	  	  	  	8
2 	169.10 	85.05 	  	  	  	  	P 	762.35 	381.68 	745.33 	373.17 	744.34 	372.67 	7
3 	226.12 	113.56 	  	  	  	  	G 	665.30 	333.15 	648.27 	324.64 	647.29 	324.15 	6
4 	373.19 	187.10 	  	  	  	  	F 	608.28 	304.64 	591.25 	296.13 	590.27 	295.64 	5
5 	430.21 	215.61 	  	  	  	  	G 	461.21 	231.11 	444.18 	222.60 	443.20 	222.10 	4
6 	545.24 	273.12 	  	  	527.22 	264.12 	D 	404.19 	202.60 	387.16 	194.08 	386.18 	193.59 	3
7 	659.28 	330.14 	642.25 	321.63 	641.27 	321.14 	N 	289.16 	145.08 	272.14 	136.57 	  	  	2
8 	  	  	  	  	  	  	R 	175.12 	88.06 	158.09 	79.55 	  	  	1}

    frag = Spectrum.new("APGFGDNR")
    identifiers.each do |identifier|
      assert_series_equal(identifier, series, frag, FRAGMENT_TEST_MASS_UNCERTAINTY)
    end
  end
  
  def identifiers2
    ['a', 'b',  'c', 'x',  'y', 'z', 'Immon.', 'z+1', 'z+2']
  end
  
  # http://hsc-mascot.uchsc.edu/mascot/cgi/peptide_view.pl?file=../data/20080125/F006779.dat&query=6&hit=1&index=TGM1_HUMAN&px=1&section=5&ave_thresh=36
  it 'fragments_vs_mascot_IVYVEEK' do
    series = mascot_series %Q{
#  	Immon.  	a  	a0  	b  	b0  	c  	Seq.  	x  	y  	y0  	z  	z+1  	z+2  	#
1 	86.10 	86.10 	  	114.09 	  	131.12 	I 	  	  	  	  	  	  	7
2 	72.08 	185.16 	  	213.16 	  	230.19 	V 	792.38 	766.40 	748.39 	749.37 	750.38 	751.39 	6
3 	136.08 	348.23 	  	376.22 	  	393.25 	Y 	693.31 	667.33 	649.32 	650.30 	651.31 	652.32 	5
4 	72.08 	447.30 	  	475.29 	  	492.32 	V 	530.25 	504.27 	486.26 	487.24 	488.25 	489.26 	4
5 	102.05 	576.34 	558.33 	604.33 	586.32 	621.36 	E 	431.18 	405.20 	387.19 	388.17 	389.18 	390.19 	3
6 	102.05 	705.38 	687.37 	733.38 	715.37 	750.40 	E 	302.13 	276.16 	258.14 	259.13 	260.14 	261.14 	2
7 	101.11 	  	  	  	  	  	K 	173.09 	147.11 	  	130.09 	131.09 	132.10 	1}

    frag = Spectrum.new("IVYVEEK")
    identifiers2.each do |identifier|
      assert_series_equal(identifier, series, frag, FRAGMENT_TEST_MASS_UNCERTAINTY)
    end
  end
  
    #http://hsc-mascot.uchsc.edu/mascot/cgi/peptide_view.pl?file=../data/20080125/F006779.dat&query=40&hit=1&index=TGM1_HUMAN&px=1&section=5&ave_thresh=36
  it 'fragments_vs_mascot_RPDLPSGFDGWQVVDATPQETSSGIFCCGPCSVESIK' do
    series = mascot_series %Q{
#  	Immon.  	a  	a*  	a0  	b  	b*  	b0  	c  	d  	d'  	Seq.  	x  	y  	y0  	z  	z+1  	z+2  	#
1 	129.11 	129.11 	112.09 	  	157.11 	140.08 	  	174.13 	44.05 	  	R 	  	  	  	  	  	  	37
2 	70.07 	226.17 	209.14 	  	254.16 	237.13 	  	271.19 	200.15 	  	P 	3782.67 	3756.69 	3738.68 	3739.66 	3740.67 	3741.68 	36
3 	88.04 	341.19 	324.17 	323.18 	369.19 	352.16 	351.18 	386.21 	297.20 	  	D 	3685.61 	3659.63 	3641.62 	3642.61 	3643.62 	3644.62 	35
4 	86.10 	454.28 	437.25 	436.27 	482.27 	465.25 	464.26 	499.30 	412.23 	  	L 	3570.59 	3544.61 	3526.60 	3527.58 	3528.59 	3529.60 	34
5 	70.07 	551.33 	534.30 	533.32 	579.32 	562.30 	561.31 	596.35 	525.31 	  	P 	3457.50 	3431.52 	3413.51 	3414.50 	3415.50 	3416.51 	33
6 	60.04 	638.36 	621.34 	620.35 	666.36 	649.33 	648.35 	683.38 	622.37 	  	S 	3360.45 	3334.47 	3316.46 	3317.44 	3318.45 	3319.46 	32
7 	30.03 	695.38 	678.36 	677.37 	723.38 	706.35 	705.37 	740.40 	  	  	G 	3273.42 	3247.44 	3229.43 	3230.41 	3231.42 	3232.43 	31
8 	120.08 	842.45 	825.43 	824.44 	870.45 	853.42 	852.44 	887.47 	  	  	F 	3216.40 	3190.42 	3172.41 	3173.39 	3174.40 	3175.41 	30
9 	88.04 	957.48 	940.45 	939.47 	985.47 	968.45 	967.46 	1002.50 	913.49 	  	D 	3069.33 	3043.35 	3025.34 	3026.32 	3027.33 	3028.34 	29
10 	30.03 	1014.50 	997.47 	996.49 	1042.50 	1025.47 	1024.48 	1059.52 	  	  	G 	2954.30 	2928.32 	2910.31 	2911.29 	2912.30 	2913.31 	28
11 	159.09 	1200.58 	1183.55 	1182.57 	1228.57 	1211.55 	1210.56 	1245.60 	  	  	W 	2897.28 	2871.30 	2853.29 	2854.27 	2855.28 	2856.29 	27
12 	101.07 	1328.64 	1311.61 	1310.63 	1356.63 	1339.61 	1338.62 	1373.66 	1271.62 	  	Q 	2711.20 	2685.22 	2667.21 	2668.19 	2669.20 	2670.21 	26
13 	72.08 	1427.71 	1410.68 	1409.70 	1455.70 	1438.67 	1437.69 	1472.73 	1413.69 	  	V 	2583.14 	2557.16 	2539.15 	2540.14 	2541.14 	2542.15 	25
14 	72.08 	1526.78 	1509.75 	1508.76 	1554.77 	1537.74 	1536.76 	1571.80 	1512.76 	  	V 	2484.07 	2458.09 	2440.08 	2441.07 	2442.07 	2443.08 	24
15 	88.04 	1641.80 	1624.78 	1623.79 	1669.80 	1652.77 	1651.79 	1686.82 	1597.81 	  	D 	2385.00 	2359.03 	2341.01 	2342.00 	2343.01 	2344.01 	23
16 	44.05 	1712.84 	1695.81 	1694.83 	1740.83 	1723.81 	1722.82 	1757.86 	  	  	A 	2269.98 	2244.00 	2225.99 	2226.97 	2227.98 	2228.99 	22
17 	74.06 	1813.89 	1796.86 	1795.88 	1841.88 	1824.86 	1823.87 	1858.91 	1797.89 	1799.87 	T 	2198.94 	2172.96 	2154.95 	2155.93 	2156.94 	2157.95 	21
18 	70.07 	1910.94 	1893.91 	1892.93 	1938.93 	1921.91 	1920.92 	1955.96 	1884.92 	  	P 	2097.89 	2071.91 	2053.90 	2054.89 	2055.89 	2056.90 	20
19 	101.07 	2039.00 	2021.97 	2020.99 	2066.99 	2049.97 	2048.98 	2084.02 	1981.98 	  	Q 	2000.84 	1974.86 	1956.85 	1957.83 	1958.84 	1959.85 	19
20 	102.05 	2168.04 	2151.01 	2150.03 	2196.04 	2179.01 	2178.03 	2213.06 	2110.04 	  	E 	1872.78 	1846.80 	1828.79 	1829.78 	1830.78 	1831.79 	18
21 	74.06 	2269.09 	2252.06 	2251.08 	2297.08 	2280.06 	2279.07 	2314.11 	2253.09 	2255.07 	T 	1743.74 	1717.76 	1699.75 	1700.73 	1701.74 	1702.75 	17
22 	60.04 	2356.12 	2339.09 	2338.11 	2384.12 	2367.09 	2366.10 	2401.14 	2340.13 	  	S 	1642.69 	1616.71 	1598.70 	1599.69 	1600.69 	1601.70 	16
23 	60.04 	2443.15 	2426.13 	2425.14 	2471.15 	2454.12 	2453.14 	2488.17 	2427.16 	  	S 	1555.66 	1529.68 	1511.67 	1512.65 	1513.66 	1514.67 	15
24 	30.03 	2500.17 	2483.15 	2482.16 	2528.17 	2511.14 	2510.16 	2545.20 	  	  	G 	1468.63 	1442.65 	1424.64 	1425.62 	1426.63 	1427.64 	14
25 	86.10 	2613.26 	2596.23 	2595.25 	2641.25 	2624.23 	2623.24 	2658.28 	2585.23 	2599.24 	I 	1411.61 	1385.63 	1367.62 	1368.60 	1369.61 	1370.62 	13
26 	120.08 	2760.33 	2743.30 	2742.32 	2788.32 	2771.29 	2770.31 	2805.35 	  	  	F 	1298.52 	1272.54 	1254.53 	1255.52 	1256.52 	1257.53 	12
27 	76.02 	2863.34 	2846.31 	2845.33 	2891.33 	2874.30 	2873.32 	2908.36 	2831.36 	  	C 	1151.45 	1125.47 	1107.46 	1108.45 	1109.45 	1110.46 	11
28 	76.02 	2966.34 	2949.32 	2948.33 	2994.34 	2977.31 	2976.33 	3011.37 	2934.37 	  	C 	1048.44 	1022.46 	1004.45 	1005.44 	1006.45 	1007.45 	10
29 	30.03 	3023.37 	3006.34 	3005.36 	3051.36 	3034.33 	3033.35 	3068.39 	  	  	G 	945.43 	919.46 	901.44 	902.43 	903.44 	904.44 	9
30 	70.07 	3120.42 	3103.39 	3102.41 	3148.41 	3131.39 	3130.40 	3165.44 	3094.40 	  	P 	888.41 	862.43 	844.42 	845.41 	846.42 	847.42 	8
31 	76.02 	3223.43 	3206.40 	3205.42 	3251.42 	3234.40 	3233.41 	3268.45 	3191.46 	  	C 	791.36 	765.38 	747.37 	748.35 	749.36 	750.37 	7
32 	60.04 	3310.46 	3293.43 	3292.45 	3338.46 	3321.43 	3320.44 	3355.48 	3294.47 	  	S 	688.35 	662.37 	644.36 	645.35 	646.35 	647.36 	6
33 	72.08 	3409.53 	3392.50 	3391.52 	3437.52 	3420.50 	3419.51 	3454.55 	3395.51 	  	V 	601.32 	575.34 	557.33 	558.31 	559.32 	560.33 	5
34 	102.05 	3538.57 	3521.54 	3520.56 	3566.57 	3549.54 	3548.56 	3583.59 	3480.57 	  	E 	502.25 	476.27 	458.26 	459.24 	460.25 	461.26 	4
35 	60.04 	3625.60 	3608.58 	3607.59 	3653.60 	3636.57 	3635.59 	3670.62 	3609.61 	  	S 	373.21 	347.23 	329.22 	330.20 	331.21 	332.22 	3
36 	86.10 	3738.69 	3721.66 	3720.68 	3766.68 	3749.66 	3748.67 	3783.71 	3710.66 	3724.67 	I 	286.18 	260.20 	  	243.17 	244.18 	245.19 	2
37 	101.11 	  	  	  	  	  	  	  	  	  	K 	173.09 	147.11 	  	130.09 	131.09 	132.10 	1}

    frag = Spectrum.new("RPDLPSGFDGWQVVDATPQETSSGIFCCGPCSVESIK")
    identifiers2.each do |identifier|
      assert_series_equal(identifier, series, frag, FRAGMENT_TEST_MASS_UNCERTAINTY)
    end
  end
  
end