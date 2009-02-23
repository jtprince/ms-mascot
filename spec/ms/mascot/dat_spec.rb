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
  xit 'filters hits and returns an mgf file' do
    Dat.open(@file) do |obj|
      low_hits = obj.summary.peptide_hits.select do |hit|
        hit.score < 20
      end
      scan_nums = low_hits.map do |hit|
        hit.scan_num
      end
      query = scan_nums.map {|sn| obj.to_mgf(sn) }
    end
  end
end


