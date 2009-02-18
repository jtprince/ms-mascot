require 'ms/in_silico/fragment'
require 'ms/mascot/spectrum'

module Ms
  module Mascot
  
    # Ms::Mascot::Fragment::manifest calculates a theoretical Mascot ms/ms spectrum
    class Fragment < InSilico::Fragment
      
      def headers(spec)
        {
          :charge => charge,
          :parent_ion_mass => spec.parent_ion_mass(charge),
          :title => "#{spec.sequence} (#{series.join(', ')})"
        }
      end
      
      def spectrum(peptide)
        Mascot::Spectrum.new(peptide, nterm, cterm)
      end
      
    end
  end
end