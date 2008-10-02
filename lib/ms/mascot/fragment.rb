require 'ms/in_silico/fragment'
require 'ms/mascot/spectrum'

module Ms
  module Mascot
  
    # ::manifest
    class Fragment < InSilico::Fragment
      include Constants::Libraries
      include Molecules::Libraries
      
      config(:mass_map, {}) do |value|
        case value
        when Hash
          map = {}
          value.each_pair do |key, value|
            unless map.has_key?(key) 
              key = (key =~ /electron/i ? Particle::ELECTRON : Element[key] || Residue[key])
            end
            
            unless key
              raise "no constant mapped to key: #{key}"
            end
            
            unless value.kind_of?(array)
              raise "value should be an [monoisotopic, average] mass array: #{value} (#{key})"
            end
            
            map[key] = value.collect {|value| value.to_f }
          end
          
          map
        else
          raise "mass_map should be a Hash"
        end
      end
      
      def spectrum(peptide)
        spec = Mascot::Spectrum.new(peptide, nterm, cterm)
        spec.mass_map.merge!(mass_map)
        spec
      end
      
    end
  end
end