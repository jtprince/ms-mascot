require 'ms/mascot/dat/section'

class Ms::Mascot::Dat
  
  # Proteins represent supplementary protein information in a dat file.
  #
  #   Content-Type: application/x-Mascot; name="proteins"
  #   
  #   "ZN711_HUMAN"=87153.77,"Zinc finger protein 711 (Zinc finger protein 6) - Homo sapiens (Human)"
  #   "Y986_MYCTU"=27356.31,"Hypothetical ABC transporter ATP-binding protein Rv0986/MT1014 - Mycobacterium tuberculosis"
  #   "Y5G0_ENCCU"=33509.30,"Hypothetical protein ECU05_1600/ECU11_0130 - Encephalitozoon cuniculi"
  #
  # Proteins is (almost) a standard Section and defines methods for convenient
  # access.
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
    
    # A format string used to format parameters as a string.
    TO_S_FORMAT = "\"%s\"=%s\n"
    
    class << self
      
      # Parses a new instance from str.  Special parsing is required to quickly
      # remove the quotes from protein keys.
      def parse(str, sec_name=nil, archive=nil)
        sec_name ||= to_s.split('::').last.downcase
        
        params = {}
        scanner = StringScanner.new(str)
        
        # scan each pair removing quotes from keys
        while true
          scanner.skip(/"/)
          break unless key = scanner.scan(/[^"]+/)
          scanner.skip(/"\=/)
          params[key] = scanner.scan(/[^\n]*/)
          scanner.skip(/\n/)
        end
        
        new(params, sec_name, archive)
      end
    end
    
    # Returns a Protein for the specified protein id.
    def protein(id)
      parse_protein(data[id])
    end 
    
    private
    
    # Parses a Protein from the protien data string.
    def parse_protein(str)
      return nil unless str
      mass, description = str.split(',')
      Protein.new(mass.to_f, description[1...-1])
    end
  end
end
