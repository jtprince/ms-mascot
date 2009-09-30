require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/dat/peptides'

class PeptidesUtilsSpec < MiniTest::Spec
  include Ms::Mascot::Dat::Peptides::Utils
  
  #
  # describe parse_peptide_hit
  #
  
  it "parses a PeptideHit from input data" do
    hit_str = %Q{0,499.300598,-0.051862,2,LAVPT,10,0000000,3.87,0001002000000000000,0,0;"Y1319_MYCTU":0:531:535:1,"Y1353_MYCBO":0:532:536:1}
    terms_str = "R,-:K,-"
    
    hit = parse_peptide_hit(hit_str, terms_str)
    hit.n_missed_cleavages.must_equal 0
    hit.sequence.must_equal 'LAVPT'
    hit.score.must_equal 3.87
    hit.unknown8.must_equal '0001002000000000000'
    hit.protein_maps.length.must_equal 2
    
    protein_map = hit.protein_maps[0]
    protein_map.id.must_equal 'Y1319_MYCTU'
    protein_map.peptide_end.must_equal 535
    protein_map.cterm.must_equal '-'
    
    protein_map = hit.protein_maps[1]
    protein_map.peptide_start.must_equal 532
    protein_map.nterm.must_equal 'K'
  end

  it "returns nil for nil hit string" do
    parse_peptide_hit(nil, "").must_equal nil
  end
  
  it "returns nil for hit string of '-1'" do
    parse_peptide_hit("-1", "").must_equal nil
  end
end

class PeptidesSpec < MiniTest::Spec
  include Ms::Mascot
  
  # From sample mascot data F981122.dat
  SAMPLE_PEPTIDES = %Q{q1_p1=-1
q2_p1=0,499.300598,-0.051862,2,LAVPT,10,0000000,3.87,0001002000000000000,0,0;"Y1319_MYCTU":0:531:535:1,"Y1353_MYCBO":0:531:535:1
q2_p1_terms=R,-:R,-
q2_p2=0,499.300598,-0.051862,2,LAVTP,10,0000000,3.87,0001002000000000000,0,0;"RLPA_RICCN":0:316:320:1
q2_p2_terms=K,-
q2_p3=0,499.336990,-0.088254,2,LAVVV,10,0000000,3.87,0001002000000000000,0,0;"DYNA_NEUCR":0:1296:1300:1
q2_p3_terms=R,-
}
  
  attr_reader :peptides
  
  before do
    @peptides = Dat::Peptides.parse SAMPLE_PEPTIDES
  end
  
  #
  # describe queries
  #
  
  it "returns an array of PeptideHit arrays for the all queries" do
    queries = peptides.queries
    queries.length.must_equal 3
    
    # boundary conditions
    queries[0].must_equal nil
    queries[1].empty?.must_equal true
    
    hit = queries[2][2]
    hit.sequence.must_equal "LAVTP"
    hit.protein_maps[0].id.must_equal 'RLPA_RICCN'
  end
  
  it "does not resolve all peptide hits unless specified" do
    peptides.queries(false).empty?.must_equal true
  end
  
  #
  # describe peptide_hits
  #
  
  it "returns an array of PeptideHits for the specified query" do
    hits = peptides.peptide_hits(2)
    hits.length.must_equal 4
    hits[0].must_equal nil
    
    hit = hits[3]
    hit.sequence.must_equal "LAVVV"
    hit.delta_mass.must_equal(-0.088254)
    hit.protein_maps[0].id.must_equal 'DYNA_NEUCR'
  end
  
  it "returns an empty array when there are no hits for the query" do
    peptides.peptide_hits(1).must_equal []
  end
  
  it "returns a nil when there is no such query" do
    peptides.peptide_hits(10).must_equal nil
  end
  
  #
  # describe peptide_hit
  #
  
  it "returns a PeptideHit for the specified query-hit" do
    hit = peptides.peptide_hit(2,1)
    hit.sequence.must_equal 'LAVPT'
    hit.score.must_equal 3.87
    hit.protein_maps[0].id.must_equal 'Y1319_MYCTU'
  end
  
  it "returns a nil when there are no hits for the query" do
    peptides.peptide_hit(1,1).must_equal nil
  end
  
  it "returns a nil when there is no such query" do
    peptides.peptide_hit(10,1).must_equal nil
  end
end
