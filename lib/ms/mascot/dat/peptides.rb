require 'ms/mascot/dat/section'

module Ms::Mascot::Dat
  
  # Peptides represent peptide identification information in a dat file.
  #
  #   Content-Type: application/x-Mascot; name="peptides"
  #   
  #   q1_p1=-1
  #   q2_p1=0,499.300598,-0.051862,2,LAVPT,10,0000000,3.87,0001002000000000000,0,0;"Y1319_MYCTU":0:531:535:1,"Y1353_MYCBO":0:531:535:1
  #   q2_p1_terms=R,-:R,-
  #   q2_p2=0,499.300598,-0.051862,2,LAVTP,10,0000000,3.87,0001002000000000000,0,0;"RLPA_RICCN":0:316:320:1
  #   q2_p2_terms=K,-
  #   q2_p3=0,499.336990,-0.088254,2,LAVVV,10,0000000,3.87,0001002000000000000,0,0;"DYNA_NEUCR":0:1296:1300:1
  #   q2_p3_terms=R,-
  #
  # Peptides is a standard Section and simply defines methods for convenient
  # access.  See Section for parsing details.
  #
  # === Interpretation
  #
  # Deciphering the peptide information requires some cross-referencing with
  # online results.  Noting that a single query can match multiple peptides:
  #
  #   qN_pN=-1                         # no matches
  #   qN_pM=peptide;protein_maps       # query N peptide hit M
  #   qN_pM_terms=A,B:C,D              # n and c-termini residues for each protein match
  #
  # See the Peptide and ProteinMap documentation for interpretation of the
  # specific query data.
  class Peptides < Ms::Mascot::Dat::Section
    
    # === PeptideHit
    #
    # Represents peptide hit data, infered by inspection of the MS/MS sample
    # results, esp {F981123.dat}[http://www.matrixscience.com/cgi/peptide_view.pl?file=../data/F981123.dat&query=2&hit=1&index=&px=1&section=5&ave_thresh=38].
    #   
    #   # 0,499.300598,-0.051862,2,LAVPT,10,0000000,3.87,0001002000000000000,0,0
    # 
    #   index  example              meaning
    #   0      0                    n Missed Cleavages
    #   1      499.300598           Monoisotopic mass of neutral peptide Mr(calc)
    #   2      -0.051862            actual - theoretical delta mass
    #   3      2
    #   4      LAVPT                matched sequence
    #   5      10
    #   6      0000000              modification sites (including n,c residues; number indicates mod)
    #   7      3.87                 peptide score
    #   8      0001002000000000000
    #   9      0
    #   10     0
    #
    # The dat file is said to be generate by Mascot version 1.0, but the headers
    # section records 2.1.119.
    #
    # ==== Modification Sequence
    #
    # The modification sequence indicates which residues are modified and includes
    # the n and c-terminal residues. The index at each location indicates the
    # modification used (0 indicates no modification).
    #
    # ==== Unaccounted for data
    #
    # Peptide data known to exist in the dat file:
    #
    #   Homology threshold
    #   Identity threshold
    #   Frame number
    #   Number of fragment ion matches
    #   Experimental charge
    #
    PeptideHit = Struct.new(
      :n_missed_cleavages,
      :peptide_mass,
      :delta_mass,
      :unknown3,
      :sequence,
      :unknown4,
      :modifications,
      :score,
      :unknown8,
      :unknown9,
      :unknown10,
      :protein_maps
    )
    
    # Indicies of Peptide terms that will be cast to floats.
    PeptideFloatIndicies = [1,2,7]
    
    # Indicies of Peptide terms that will be cast to integers.
    PeptideIntIndicies = [0,3,5,9,10]
    
    # === ProteinMap
    #
    # Represents a protein map, indicating which proteins contain the
    # identified peptide.  There may be many for a given peptide hit
    #
    #   # "Y1319_MYCTU":0:531:535:1,"Y1353_MYCBO":0:531:535:1
    #
    #   index  example              meaning
    #   0      "Y1319_MYCTU"        matching protein id
    #   1      0
    #   2      531                  peptide start index
    #   3      535                  peptide end index
    #   4      1
    #
    ProteinMap = Struct.new(
      :id,
      :uknown1,
      :peptide_start,
      :peptide_end,
      :unknown4,
      :nterm,
      :cterm
    )
    
    # Indicies of ProteinMap terms that will be cast to integers.
    ProteinMapIntIndicies = [1,2,3,4]
    
    class << self
      
      # Parses a PeptideHit from the query-hit string.
      def parse_peptide_hit(str, terms)
        return nil if str == nil || str == "-1"
        
        peptide_data, protein_maps = str.split(";", 2)
        protein_maps = protein_maps.split(",")
        terms = terms.split(":")
        
        # parse peptide data
        peptide_data = peptide_data.split(",")
        
        PeptideFloatIndicies.each do |index|
          peptide_data[index] = peptide_data[index].to_f
        end
        
        PeptideIntIndicies.each do |index|
          peptide_data[index] = peptide_data[index].to_i
        end

        # parse protein_map data
        protein_maps = protein_maps.zip(terms).collect do |map_data, terms|
          data = map_data.split(":") + terms.split(',')
          
          # removes quotes from protein id
          data[0] = data[0][1...-1]
          
          ProteinMapIntIndicies.each {|index| data[index] = data[index].to_i }
          ProteinMap.new(*data)
        end
        
        peptide_data << protein_maps
        PeptideHit.new(*peptide_data)
      end
    end
    
    def initialize(data={}, section_name=self.class.section_name, dat=nil)
      super(data, section_name, dat)
      @queries = []
    end
    
    # An array of peptides hits per query.  Specify resolve=false to return
    # the currently parsed queries.
    #
    # Note that the queries array is indexed the same as in Mascot, ie the 
    # PeptideHit for q1_p1 is located at queries[1][1], meaning there is
    # always an empty cell at queries[0].
    def queries(resolve=true)
      return @queries unless resolve
      
      query = 1
      query += 1 while peptide_hits(query)
      @queries
    end
    
    # Returns an array of PeptideHits for the specified query, or nil if no
    # such query exists.
    def peptide_hits(query)
      hit = 1
      hit += 1 while peptide_hit(query, hit)
      @queries[query]
    end
    
    # Returns the PeptideHit at the query and hit index, or nil if no such hit
    # exists.
    def peptide_hit(query, hit=1)
      key = "q#{query}_p#{hit}"
      return nil unless data.has_key?(key)
      
      hits = @queries[query] ||= []
      if existing_hit = hits[hit]
        return existing_hit
      end
      
      if parsed_hit = Peptides.parse_peptide_hit(data[key], data["#{key}_terms"])
        hits[hit] = parsed_hit
        return parsed_hit
      end
      
      nil
    end
  end
end