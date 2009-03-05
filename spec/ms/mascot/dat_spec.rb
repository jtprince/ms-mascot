require File.join(File.dirname(__FILE__), '../../tap_spec_helper.rb') 

require 'ms/mascot/dat'
require 'ms/mascot/dat/query'
require 'ms/mascot/mgf'  # for high level output spec

class DatUsageSpec < MiniTest::Spec
  include Ms::Mascot

  before do
    @file = Ms::TESTDATA + '/mascot/dat/F040565.dat'
  end
  
  #
  # describe Dat.each_query and Dat.query
  #
  
  it 'gives direct access to queries' do
    Dat.open(@file) do |dat|
      qrs = []  # for later spec
      dat.each_query do |query|
        query.must_be_kind_of Dat::Query
        qrs << query
      end
      qrs.length.must_equal 4

      qrs.each_with_index do |q,i|
        q.index.must_equal( i + 1 )
      end

      # query
      dat.query(0).must_be_nil
      dat.query(1).must_be_kind_of Dat::Query
      dat.query(2).wont_equal dat.query(1)
    end
  end

  #
  # describe Dat.each_peptide_hit
  #

  it 'gives direct access to peptide hits' do
    Dat.open(@file) do |dat|
      index = 0
      scores = [nil, 22.56, 21.43, 53.72]

      # top hit by default:
      dat.each_peptide_hit do |hit|
        if hit
          hit.query_num.must_equal(index + 1)
          hit.score.must_equal scores[index]
        else
          hit.must_equal scores[index]
        end
        index += 1
      end

      # groups of hits:
      index = 0
      dat.each_peptide_hit(:by => :groups) do |hits|
        assert hits.is_a?(Array)
        if hits.first
          hits.first.score.must_equal scores[index]
        else # means no hits for that query
          hits.first.must_equal scores[index]
        end
        index += 1
      end

      # all hits
      seen = 0
      dat.each_peptide_hit(:by => :all) do |hit|
        seen += 1
      end
      seen.must_equal 31

      # can skip nil entries
      seen = 0
      dat.each_peptide_hit(:yield_nil => false) do |hit|
        hit.wont_equal nil
        seen += 1
      end
      seen.must_equal 3

      seen = 0
      dat.each_peptide_hit(:by => :groups, :yield_nil => false) do |hits|
        hits.first.wont_equal nil
        seen += 1
      end
      seen.must_equal 3

      seen = 0
      dat.each_peptide_hit(:by => :all, :yield_nil => false) do |hit|
        hit.wont_equal nil
        seen += 1
      end
      seen.must_equal 30

      # can return query object in tandem
      dat.each_peptide_hit(:with_query => true) do |hit, query|
        if hit
          hit.respond_to?(:score).must_equal true
        end
        query.must_be_kind_of Dat::Query
      end

    end


  end
  
  #
  # describe Dat.section_names
  #
  
  it 'lists section names' do
    #p method_root
    Dat.open(@file) do |dat|
      dat.section_names.must_equal ["parameters", "masses", "unimod", "enzyme", "header", "summary", "decoy_summary", "peptides", "decoy_peptides", "proteins", "query1", "query2", "query3", "query4", "index"]
    end
  end
  
  #
  # describe Dat.section
  #
  
  it 'returns sections' do
    # some of these are currently just Strings, but there they are.
    Dat.open(@file) do |dat|
      %w(parameters masses unimod enzyme header summary decoy_summary peptides decoy_peptides proteins index).each do |meth|
        dat.section(meth).wont_be_nil
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
    Dat.open(@file) do |dat|
      %w(parameters header masses index).each do |sec|
        hash = dat.section(sec).data
        hash.must_be_kind_of Hash
        hash.size.must_be :>=, 5
      end
      # just to make sure the content is there:
      dat.section('parameters').data['TOLU'].must_equal 'ppm'
      dat.section('header').data['date'].must_equal '1232579902'
      dat.section('masses').data['C'].must_equal '103.009185'
      dat.section('index').data['summary'].must_equal '495'
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


