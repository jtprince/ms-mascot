require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/dat/summary'

class SummaryUtilsSpec < MiniTest::Spec
  include Ms::Mascot::Dat::Summary::Utils
  
  #
  # describe parse_protein_hit
  #
  
  it "parses a ProteinHit from input data" do
    hit_str = %Q{CH60_HUMAN,1.40e+03,0.48,61016.38}

    hit = parse_protein_hit(hit_str, "description", [1,2,3])
    hit.id.must_equal 'CH60_HUMAN'
    hit.mass.must_equal 61016.38
    hit.text.must_equal "description"
    hit.query_hits.must_equal [1,2,3]
  end
  
  #
  # describe parse_query_hit
  #
  
  it "parses a QueryHit from input data" do
    hit_str = %Q{0,832.382767,-0.032939,302,309,6.00,APGFGDNR,16,0000000000,45.35,1,0000002000000000000,0,0,3481.990000}
    terms_str = "K,R"
    
    hit = parse_query_hit(hit_str, terms_str)
    hit.n_missed_cleavages.must_equal 0
    hit.sequence.must_equal 'APGFGDNR'
    hit.score.must_equal 45.35
    hit.unknown11.must_equal '0000002000000000000'
    hit.nterm.must_equal 'K'
  end

  it "returns nil for nil hit string" do
    parse_query_hit(nil, "").must_equal nil
  end
  
  it "returns nil for hit string of '-1'" do
    parse_query_hit("-1", "").must_equal nil
  end
end

class SummarySpec < MiniTest::Spec
  include Ms::Mascot::Dat

  # From sample mascot data F981122.dat, slightly modified
  SAMPLE_SUMMARY = %Q{

Content-Type: application/x-Mascot; name="summary"

qmass1=497.265612
qexp1=498.272888,1+
qmatch1=5360
qplughole1=0.000000
qmass2=499.248736
qexp2=500.256012,1+
qmatch2=5759
qplughole2=16.873721
h1=CH60_HUMAN,1.40e+03,0.48,61016.38
h1_text=60 kDa heat shock protein, mitochondrial precursor (Hsp60) (60 kDa chaperonin) (CPN60) (Heat shock 
h1_q1=-1
h1_q2=-1
h1_q3=0,832.382767,-0.032939,302,309,6.00,APGFGDNR,16,0000000000,45.35,1,0000002000000000000,0,0,3481.990000
h1_q3_terms=K,K
h1_q4=0,843.506577,-0.034557,345,352,7.00,VGEVIVTK,24,0000000000,45.74,2,0001002000000000000,0,0,1662.450000
h1_q4_terms=K,D
h2=CH60_PONPY,1.15e+03,0.39,60959.33
h2_text=60 kDa heat shock protein, mitochondrial precursor (Hsp60) (60 kDa chaperonin) (CPN60) (Heat shock 
h2_q1=-1
h2_q2=0,832.382767,-0.032939,302,309,6.00,APGFGDNR,16,0000000000,45.35,1,0000002000000000000,0,0,3481.990000
h2_q2_terms=K,K
h2_q3=-1
}

  attr_reader :summary

  before do
    @summary = Summary.parse SAMPLE_SUMMARY
  end
  
  #
  # describe protein_hits
  #
  
  it "returns an array of ProteinHits for the all hits" do
    hits = summary.protein_hits
    hits.length.must_equal 3
    
    # boundary condition
    hits[0].must_equal nil
    
    hit = hits[2]
    hit.id.must_equal "CH60_PONPY"
    hit.query_hits[2].sequence.must_equal 'APGFGDNR'
    hit.query_hits[3].must_equal nil
  end
  
  it "does not resolve all protein hits unless specified" do
    summary.protein_hits(false).empty?.must_equal true
  end
  
  #
  # describe protein_hit
  #
  
  it "returns a ProteinHit for the specified hit" do
    hit = summary.protein_hit(1)
    hit.text.must_equal '60 kDa heat shock protein, mitochondrial precursor (Hsp60) (60 kDa chaperonin) (CPN60) (Heat shock '
    hit.mass.must_equal 61016.38
    hit.query_hits.length.must_equal 5
    
    query = hit.query_hits[4]
    query.sequence.must_equal "VGEVIVTK"
  end
  
  it "returns a nil when there is no such hit" do
    summary.protein_hit(2).must_equal nil
  end
  
  #
  # describe query_hits
  #
  
  it "returns an array of QueryHits for the specified hit" do
    hits = summary.query_hits(1)
    hits.length.must_equal 5
    hits[0].must_equal nil
    hits[1].must_equal nil
    
    hit = hits[4]
    hit.unknown11.must_equal "0001002000000000000"
    hit.peptide_start.must_equal 345
    hit.cterm.must_equal 'D'
  end
  
  it "returns a nil when there is no such hit" do
    summary.query_hits(10).must_equal nil
  end
  
  #
  # describe query_hit
  #
  
  it "returns a QueryHit for the specified hit-query" do
    hit = summary.query_hit(1,3)
    hit.sequence.must_equal 'APGFGDNR'
    hit.delta_mass.must_equal(-0.032939)
    hit.cterm.must_equal 'K'
  end
  
  it "returns a nil when there is no such query" do
    summary.query_hit(1,1).must_equal nil
    summary.query_hit(1,13).must_equal nil
    summary.query_hit(10,1).must_equal nil
  end
end