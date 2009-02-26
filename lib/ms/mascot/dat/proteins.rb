require 'ms/mascot/dat/section'

module Ms::Mascot::Dat
  
  # Proteins represent supplementary protein information in a dat file.
  #
  #   Content-Type: application/x-Mascot; name="proteins"
  #   
  #   "ZN711_HUMAN"=87153.77,"Zinc finger protein 711 (Zinc finger protein 6) - Homo sapiens (Human)"
  #   "Y986_MYCTU"=27356.31,"Hypothetical ABC transporter ATP-binding protein Rv0986/MT1014 - Mycobacterium tuberculosis"
  #   "Y5G0_ENCCU"=33509.30,"Hypothetical protein ECU05_1600/ECU11_0130 - Encephalitozoon cuniculi"
  #
  # Proteins is a standard Section and simply defines methods for convenient
  # access.  See Section for parsing details.
  class Proteins < Section
    
    # === Protein
    #
    # Represents protein data.
    #
    #   # 87153.77,"Zinc finger protein 711 (Zinc finger protein 6) - Homo sapiens (Human)"
    #
    #   index  example              meaning
    #   0      87153.77             protein mass in Da
    #   1      "Zinc finger..."     a description string
    #
    Protein = Struct.new(
      :mass,
      :description
    )
    
    class << self
      
      # Parses a new instance from str.  Special parsing is required to quickly
      # remove the quotes from protein keys.
      def parse(str, archive=nil)
        params = {}
        scanner = StringScanner.new(str)
        
        # skip whitespace and content type declaration
        unless scanner.scan(Section::CONTENT_TYPE_REGEXP)
          raise "unknown content type: #{content_type}"
        end
        section_name = scanner[1]
        
        # scan each pair removing quotes from keys
        while true
          scanner.skip(/"/)
          break unless key = scanner.scan(/[^"]+/)
          scanner.skip(/"\=/)
          params[key] = scanner.scan(/[^\n]*/)
          scanner.skip(/\n/)
        end
        
        new(params, section_name, archive)
      end
      
      # Parses a Protein from the protien data string.
      def parse_protein(str)
        return nil unless str
        mass, description = str.split(',')
        Protein.new(mass.to_f, description[1...-1])
      end
    end
    
    # Returns a Protein for the specified protein id.
    def protein(id)
      Proteins.parse_protein(data[id])
    end 
  end
end