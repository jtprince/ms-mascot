require 'ms/in_silico/fragment'
require 'ms/mascot/spectrum'

module Ms
  module Mascot
  
    # ::manifest
    class Fragment < InSilico::Fragment
      include Constants::Libraries
      include Molecules::Libraries
      
      # A map of the default [monoisotopic, average] masses for a variety
      # of constants used by Mascot.  Taken from the configuration pages
      # on the Hansen Lab server:
      #
      # - http://hsc-mascot.uchsc.edu/mascot/x-cgi/ms-config.exe?u=1222975681&ELEMENTS_SHOW=1
      # - http://hsc-mascot.uchsc.edu/mascot/x-cgi/ms-config.exe?u=1222975681&AMINOACIDS_SHOW=1
      #
      DEFAULT_MASS_MAP = {
        Residue::A => [71.037114, 71.0779],
        Residue::R => [156.101111, 156.1857],
        Residue::N => [114.042927, 114.1026],
        Residue::D => [115.026943, 115.0874],
        Residue::C => [103.009185, 103.1429],
        Residue::E => [129.042593, 129.1140],
        Residue::Q => [128.058578, 128.1292],
        Residue::G => [57.021464, 57.0513],
        Residue::H => [137.058912, 137.1393],
        Residue::I => [113.084064, 113.1576],
        Residue::L => [113.084064, 113.1576],
        Residue::K => [128.094963, 128.1723],
        Residue::M => [131.040485, 131.1961],
        Residue::F => [147.068414, 147.1739],
        Residue::P => [97.052764, 97.1152],
        Residue::S => [87.032028, 87.0773],
        Residue::T => [101.047679, 101.1039],
        Residue::W => [186.079313, 186.2099],
        Residue::Y => [163.063329, 163.1733],
        Residue::V => [99.068414, 99.1311],

        Element::Ag => [106.905092, 107.8682],
        Element::Au => [196.966543, 196.96655],
        Element::Br => [78.9183361, 79.904],
        Element::C => [12, 12.0107],
        Element::Ca => [39.9625906, 40.078],
        Element::Cl => [34.96885272, 35.453],
        Element::Cu => [62.9295989, 63.546],
        Element::F => [18.99840322, 18.9984032],
        Element::Fe  => [55.9349393, 55.845],
        Element::H => [1.007825035, 1.00794],
        Element::Hg => [201.970617, 200.59],
        Element::I => [126.904473, 126.90447],
        Element::K => [38.9637074, 39.0983],
        Element::Li => [7.016003, 6.941],
        Element::Mo => [97.9054073, 95.94],
        Element::N => [14.003074, 14.0067],
        Element::Na => [22.9897677, 22.98977],
        Element::Ni => [57.9353462, 58.6934],
        Element::O => [15.99491463, 15.9994],
        Element::P => [30.973762, 30.973761],
        Element::S => [31.9720707, 32.065],
        Element::Se => [79.9165196, 78.96],
        Element::Zn => [63.9291448, 65.409], 

        '13C'  => [13.00335483, 13.00335483],
        '15N'  => [15.00010897, 15.00010897],
        '18O'  => [17.9991603, 17.9991603],
        '2H'  => [2.014101779, 2.014101779],
        
        'N-term' => [1.007825, 1.0079],
        'C-term' => [17.002740, 17.0073],
        Particle::ELECTRON => [0.000549, 0.000549]
      }
      
      config(:mass_map, DEFAULT_MASS_MAP) do |value|
        case value
        when DEFAULT_MASS_MAP then value
        when Hash
          map = DEFAULT_MASS_MAP.dup
          
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
      
      config :nterm, nil          # the n-terminal modification
      config :cterm, nil         # the c-terminal modification
      
      def residue_masses
        Residue.residue_index.collect do |residue| 
          next(0) if residue == nil
          mass_map[residue][0]
        end
      end
      
      def spectrum(peptide)
        Mascot::Spectrum.new(peptide, 
          nterm || mass_map['N-term'][0],
          cterm || mass_map['C-term'][0],
          residue_masses,
          mass_map[Particle::ELECTRON][0]
        ) do |const|
          const = mass_map[const]
          const ? const[0] : const.mass
        end
      end
      
    end
  end
end