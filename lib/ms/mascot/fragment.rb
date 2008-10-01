require 'ms/in_silico/fragment'
require 'ms/mascot/fragment_spectrum'

module Ms
  module Mascot
  
    # ::manifest
    class Fragment < InSilico::Fragment
      config :precision, 6
      
      def fragment_spectrum(peptide)
        Mascot::FragmentSpectrum.new(peptide, nterm, cterm, precision)
      end
    end
  end
end