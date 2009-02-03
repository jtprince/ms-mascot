require File.join(File.dirname(__FILE__), '../../tap_spec_helper.rb') 
require 'ms/mascot/dat'



@@file = '/home/jtprince/ms/data/090113_init/mini/F040565.dat'

describe 'Dat usage' do
  #include RequiresDatFile
  include Ms::Mascot
  Dat = Ms::Mascot.const_get('Dat')

  it 'can access queries with each_query, query(num), or query' do
    query_class = Dat.const_get 'Query'
    Dat.open(@@file) do |obj|

      # each_query
      qrs = []  # for later spec
      obj.each_query do |query|
        query.must_be_kind_of query_class
        qrs << query
      end

      # query
      obj.query(0).must_be_nil
      obj.query(1).must_be_kind_of query_class
      obj.query(2).wont_equal obj.query(1)

      # queries
      obj.queries.must_equal qrs
      obj.queries((1..2).to_a).size.must_equal 2
      obj.queries([0]).must_equal [nil]
      obj.queries([5]).must_equal [nil]
    end
  end

 
  it 'has methods to return sections' do
    # some of these are currently just Strings, but there they are.
    Dat.open(@@file) do |obj|
      %w(parameters masses unimod enzyme header summary decoy_summary peptides decoy_peptides proteins index).each do |meth|
        obj.must_respond_to meth.to_sym
      end
    end
  end

  it 'just returns hashes for applicable sections' do
    Dat.open(@@file) do |obj|
      Dat::HASHES.each do |meth|
        hash = obj.send meth.to_sym
        hash.must_be_kind_of Hash
        hash.size.must_be :>=, 5
      end
      # just to make sure the content is there:
      obj.parameters['TOLU'].must_equal 'ppm'
      obj.header['date'].must_equal '1232579902'
      obj.masses['C'].must_equal '103.009185'
      obj.index['summary'].must_equal '495'
    end
  end
end

describe 'Dat tests' do
 
  it 'indexes the file (with a byte index)' do
    ind = File.open(@@file) do |io|
      Dat.byte_index(io)
    end

    first_last = {
      'parameters' => ["LICENSE=Licensed to: HHMI / University of Colorado, Chem and Biochem. (041U000579), (1 processor).", "INTERNALS=0.0,700.0"],
      'masses' => ['A=71.037114', 'NeutralLoss2_master=0.000000'],
      'index' => ['parameters=4', 'query4=1664'],
      # these are treated a little different
      1 => ['title=JP_PM3_0113_10ul_orb1%2e5369%2e5369%2e1%2edta', ["Ions1=121.060000", "19.2"]],
      4 => ['title=JP_PM3_0113_10ul_orb1%2e2149%2e2149%2e3%2edta', ["Ions1=251.200000", "4.1"]]

    }

    %w(parameters masses index) << [1,4].each do |key|
      ind_ar = 
        if key.is_a? Integer
          ind['query'][key]
        else
          ind[key]
        end

      string = IO.read(@@file, ind_ar.last, ind_ar.first)
      lines = string.split("\n")
      lines.first.must_equal first_last[key].first
      if key.is_a? Integer
        # test the first bit of the line and last bit of the line
        s_line = lines.last.split(':')
        s_line.first.must_equal first_last[key].last.first
        s_line.last.must_equal first_last[key].last.last
      else
        lines.last.must_equal first_last[key].last
      end

    end
  end

  it 'makes hashes from strings of parameters' do
    string = "charge=3+
mass_min=234.210000
mass_max=1984.020000
int_min=1.9
int_max=7689
num_vals=748
"
    exp = {"num_vals"=>"748", "int_max"=>"7689", "int_min"=>"1.9", "mass_max"=>"1984.020000", "mass_min"=>"234.210000", "charge"=>"3+"}
    Dat.str_to_hash(string).must_equal exp
  end


end
