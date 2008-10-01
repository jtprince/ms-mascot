require 'ms/in_silico/fragment_spectrum'

module Ms
  module Mascot
    class FragmentSpectrum < InSilico::FragmentSpectrum
      include Molecules::Utils
      
      locate_residues "P"
    
      attr_reader :precision
    
      def initialize(sequence, nterm=HYDROGEN, cterm=HYDROXIDE, precision=6, &block)
        @precision = precision
      
        super(sequence, nterm, cterm, &block)
      
        [:a, :b, :c, :cladder].each {|key| mask_locations key, [-1] }
        [:x, :y, :Y, :z, :nladder].each {|key| mask_locations key, [0] }
      
        # mask prolines
        #mask_locations :c, residue_locations['P'].collect {|i| i-1}
        #mask_locations :z, residue_locations['P']
      end
    
      def proton_mass
        mass(HYDROGEN) - round(round(ELECTRON.mass, 7), precision)
      end
      
      protected
      
      def mass(molecule)
        round(round(super, 7), precision)
      end
    
      def handle_unknown_series(s)
        case s
        when /^([\w\+\-]+)+(\d+)$/
          self.series("#{$1} +H#{$2.to_i}")
        when /^(\w+)\*(\+*-*)$/
          self.series("#{$1}#{$2} -NH3")
        when /^(\w+)0(\+*-*)$/
          self.series("#{$1}#{$2} -H2O")
        when /^Immon\.(.*)$/
          self.series("immonium#{$1}")
        else
          super
        end
      end
    end
  end
end