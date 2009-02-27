require 'ms/mascot/dat/section'

module Ms::Mascot::Dat
  
  # Summary represent summary identification information in a dat file.
  # Summaries differ in their meaning depending on the type of search but the
  # content is in the same format.  Currently the APIs for each of these
  # distinct searches are mashed together although a saner approach would be
  # to separate them.
  #
  #   Content-Type: application/x-Mascot; name="summary"
  #   
  #   qmass1=497.265612
  #   qexp1=498.272888,1+
  #   qmatch1=5360
  #   qplughole1=0.000000
  #   qmass2=499.248736
  #   qexp2=500.256012,1+
  #   qmatch2=5759
  #   qplughole2=16.873721
  #   ...
  #   h1=CH60_HUMAN,1.40e+03,0.48,61016.38
  #   h1_text=60 kDa heat shock protein, mitochondrial precursor (Hsp60) (60 kDa chaperonin) (CPN60) (Heat shock 
  #   h1_q1=-1
  #   h1_q2=-1
  #   ...
  #   h1_q11=0,832.382767,-0.032939,302,309,6.00,APGFGDNR,16,0000000000,45.35,1,0000002000000000000,0,0,3481.990000
  #   h1_q11_terms=K,K
  #   h1_q12=0,843.506577,-0.034557,345,352,7.00,VGEVIVTK,24,0000000000,45.74,2,0001002000000000000,0,0,1662.450000
  #   h1_q12_terms=K,D
  #   ...
  #
  # Summary is a standard Section and simply defines methods for convenient
  # access.  See Section for parsing details.
  #
  # === Interpretation
  #
  # Deciphering the protein hit information requires some cross-referencing with
  # online results.  Note that each hit references each query.
  #
  #   hN=protein                       # protein hit N
  #   hN_text=description              # description for hit N
  #   hN_qM=-1                         # no peptide from query
  #   hN_qM=query                      # match for hit N from query M
  #   hN_qM=A,B:C,D                    # n and c-termini residues for each protein match
  #
  # See the ProteinHit and QueryHit structures for interpretation of the
  # specific hit data.
  #--
  #
  class Summary < Section
    
    # === ProteinHit
    #
    # Represents protein hit data, infered by inspection of the MS/MS sample
    # results, esp {F981123.dat}[http://www.matrixscience.com/cgi/peptide_view.pl?file=../data/F981123.dat&query=2&hit=1&index=&px=1&section=5&ave_thresh=38].
    #   
    #   # str:  CH60_HUMAN,1.40e+03,0.48,61016.38
    #   # desc: 60 kDa heat shock protein...
    # 
    #   index  example              meaning
    #   0      CH60_HUMAN           id
    #   1      1.40e+03             
    #   2      0.48                 
    #   3      61016.38             mass
    #   4      60 kDa heat...       text
    #
    ProteinHit = Struct.new(
      :id,
      :unknown1,
      :unknown2,
      :mass,
      :text,
      :query_hits
    )
    
    # Indicies of ProteinHit terms that will be cast to floats.
    ProteinHitFloatIndicies = [1,2,3]
    
    # === QueryHit
    #
    # Represents query data, infered by inspection of the MS/MS sample
    # results, esp {F981123.dat}[http://www.matrixscience.com/cgi/peptide_view.pl?file=../data/F981123.dat&query=2&hit=1&index=&px=1&section=5&ave_thresh=38].
    #   
    #   # str:   0,832.382767,-0.032939,302,309,6.00,APGFGDNR,16,0000000000,45.35,1,0000002000000000000,0,0,3481.990000
    #   # terms: K,R
    #
    #   index  example              meaning
    #   0      0                    n Missed Cleavages
    #   1      832.382767           Monoisotopic mass of neutral peptide Mr(calc)
    #   2      -0.032939            actual - theoretical delta mass
    #   3      302                  peptide start index
    #   4      309                  peptide end index
    #   5      6.00
    #   6      APGFGDNR             peptide sequence
    #   7      16
    #   8      0000000000           modification sites (including n,c residues; number indicates mod)
    #   9      45.35                score
    #   10     1
    #   11     0000002000000000000
    #   12     0
    #   13     0
    #   14     3481.990000
    #   15     K                    nterm
    #   16     R                    cterm
    #
    # The dat file is said to be generate by Mascot version 1.0, but the headers
    # section records 2.1.119.
    QueryHit = Struct.new(
      :n_missed_cleavages,
      :peptide_mass,
      :delta_mass,
      :peptide_start,
      :peptide_end,
      :unknown5,
      :sequence,
      :unknown7,
      :modifications,
      :score,
      :unknown10,
      :unknown11,
      :unknown12,
      :unknown13,
      :unknown14,
      :nterm,
      :cterm
    )
    
    # Indicies of QueryHit terms that will be cast to floats.
    QueryHitFloatIndicies = [1,2,5,9,14]
    
    # Indicies of QueryHit terms that will be cast to integers.
    QueryHitIntIndicies = [0,3,4,7,10,12,13]
    
    module Utils
      module_function
      
      # Parses a ProteinHit from the hit string.
      def parse_protein_hit(str, desc, query_hits)
        data = str.split(",")
        ProteinHitFloatIndicies.each do |index|
          data[index] = data[index].to_f
        end
        data << desc
        data << query_hits
        
        ProteinHit.new(*data)
      end
      
      # Parses a QueryHit from the hit-query string.
      def parse_query_hit(str, terms)
        return nil if str == nil || str == "-1"
        
        data = str.split(",") + terms.split(",")
        QueryHitFloatIndicies.each do |index|
          data[index] = data[index].to_f
        end
        QueryHitIntIndicies.each do |index|
          data[index] = data[index].to_i
        end
        
        QueryHit.new(*data)
      end
    end
    
    include Utils
    
    def initialize(data={}, section_name=self.class.section_name, dat=nil)
      super(data, section_name, dat)
      @protein_hits = []
      @query_hits = []
    end
    
    # An array of protein hits.  Specify resolve=false to return just the
    # currently parsed hits.
    #
    # Note that the hits array is indexed the same as in Mascot, ie the 
    # ProteinHit for h1 is located at hits[1], meaning there is always
    # an empty cell at hits[0].
    def protein_hits(resolve=true)
      return @protein_hits unless resolve
      
      hit = 1
      hit += 1 while protein_hit(hit)
      @protein_hits
    end
    
    # Returns a ProteinHit at the hit index, or nil if no such hit exists.
    def protein_hit(hit)
      key = "h#{hit}"
      return nil unless str = data[key]
      @protein_hits[hit] ||= parse_protein_hit(str, data["#{key}_text"], query_hits(hit))
    end
    
    # Returns an array of QueryHits for the specified hit, or nil if no
    # such hit exists.
    def query_hits(hit)
      query = 1
      while data.has_key?("h#{hit}_q#{query}")
        query_hit(hit, query)
        query += 1 
      end
      
      @query_hits[hit]
    end
    
    # Returns the QueryHit at the hit and query index, or nil if no such query
    # exists.
    def query_hit(hit, query)
      key = "h#{hit}_q#{query}"
      return nil unless data.has_key?(key)
      
      queries = @query_hits[hit] ||= []
      if existing_query = queries[query]
        return existing_query
      end
      
      if parsed_query = parse_query_hit(data[key], data["#{key}_terms"])
        queries[query] = parsed_query
        return parsed_query
      end
      
      nil
    end
  end
end
