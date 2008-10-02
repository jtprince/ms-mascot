require 'ms/in_silico/spectrum'

module Ms
  module Mascot
    class Spectrum < InSilico::Spectrum
      include Molecules::Utils
      
      locate_residues "P"
    
      def initialize(*args)
        super
        
        [:a, :b, :c, :cladder].each {|key| mask_locations key, [-1] }
        [:x, :y, :Y, :z, :nladder].each {|key| mask_locations key, [0] }
      
        # mask prolines
        #mask_locations :c, residue_locations['P'].collect {|i| i-1}
        #mask_locations :z, residue_locations['P']
      end
      
      protected
    
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