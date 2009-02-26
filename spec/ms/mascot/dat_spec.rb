require File.join(File.dirname(__FILE__), '../../tap_spec_helper.rb') 
require 'ms/mascot/dat'
require 'ms/mascot/dat/query'

class DatUsageSpec < MiniTest::Spec
  include Ms::Mascot

  before do
    @file = Ms::TESTDATA + '/mascot/dat/F040565.dat'
  end
  
  #
  # describe Dat.query
  #
  
  it 'gives direct access to queries' do
    Dat.open(@file) do |obj|
      qrs = []  # for later spec
      obj.each_query do |query|
        query.must_be_kind_of Dat::Query
        qrs << query
      end
      qrs.length.must_equal 4

      qrs.each_with_index do |q,i|
        q.index.must_equal( i + 1 )
      end

      # query
      obj.query(0).must_be_nil
      obj.query(1).must_be_kind_of Dat::Query
      obj.query(2).wont_equal obj.query(1)
    end
  end
  
  #
  # describe Dat.section_names
  #
  
  it 'lists section names' do
    #p method_root
    Dat.open(@file) do |obj|
      obj.section_names.must_equal ["parameters", "masses", "unimod", "enzyme", "header", "summary", "decoy_summary", "peptides", "decoy_peptides", "proteins", "query1", "query2", "query3", "query4", "index"]
    end
  end
  
  #
  # describe Dat.section
  #
  
  it 'returns sections' do
    # some of these are currently just Strings, but there they are.
    Dat.open(@file) do |obj|
      %w(parameters masses unimod enzyme header summary decoy_summary peptides decoy_peptides proteins index).each do |meth|
        obj.section(meth).wont_be_nil
      end
    end
  end
  
  #
  # describe Dat.nqueries
  #
  
  it 'returns the number of queries in self' do
    Dat.open(@file) do |dat|
      dat.nqueries.must_equal 4
    end
  end
  
  #
  # describe Dat
  #
  
  it 'returns hashes for applicable sections' do
    Dat.open(@file) do |obj|
      %w(parameters header masses index).each do |sec|
        hash = obj.section(sec).data
        hash.must_be_kind_of Hash
        hash.size.must_be :>=, 5
      end
      # just to make sure the content is there:
      obj.section('parameters').data['TOLU'].must_equal 'ppm'
      obj.section('header').data['date'].must_equal '1232579902'
      obj.section('masses').data['C'].must_equal '103.009185'
      obj.section('index').data['summary'].must_equal '495'
    end
  end

  # high level spec
  it 'can be used to filter hits by score and reformat mgf files' do
    Dat.open(@file) do |dat|
      peptides = dat.section('peptides')
      low_hits = []
      1.upto(dat.nqueries) do |n|
        hit = peptides.peptide_hit(n)
        if hit && hit.score < 30
          pepmass = hit.peptide_mass + hit.delta_mass
          low_hits << [n, pepmass]
        end
      end
      
      # this may be optimized; the .dat file is already
      # in a data exchange format for mascot so reformatting
      # should not ultimately be necessary
      mgf = Ms::Mascot::Mgf::Archive.new
      low_hits.each do |n, pepmass|
        query = dat.query(n)
        data = query.ions
        
        headers = {}
        query.data.each_pair do |key, value|
          next if key =~ /Ions/
          headers[key.to_s.upcase] = value
        end
        headers['PEPMASS'] = pepmass
        
        mgf << Ms::Mascot::Mgf::Entry.new(headers, data)
      end
      
      mgf.length.must_equal 2
      query_two = mgf[0]
      query_two.charge.must_equal 2
      query_two.title.must_equal "JP_PM3_0113_10ul_orb1%2e1233%2e1233%2e2%2edta"
      
      query_three = mgf[1]
      query_three.charge.must_equal 1
      query_three.pepmass.must_be_within_delta(936.401093 + 0.057511, 0.000001)
    end
  end
end


