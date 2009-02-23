require 'ms/in_silico/fragment'
require 'ms/mascot/spectrum'

module Ms
  module Mascot
  
    # Ms::Mascot::Fragment::manifest calculates a theoretical Mascot ms/ms spectrum
    #
    # Calculates the theoretical Mascot ms/ms spectrum for a peptide sequence.
    # A Mascot spectrum differs from the standard in-silico spectrum only in
    # the masses that get used.  By default Mascot::Fragment uses masses with
    # 6 significant digits; the same masses that Mascot uses by default.
    #
    # In addition, Mascot::Fragment supports several alternative series notations.
    #
    #   Notation     Translation    Example
    #   series+<n>   series + Hn    a++, y0++
    #   series*      series - NH3   b*
    #   series0      series - H2O   y0
    #   Immon.       immonium       Immon.
    #
    # See Ms::Mascot::Spectrum for more details.
    class Fragment < InSilico::Fragment
      
      # Generates some MGF-specific headers.
      def headers(spec)
        {
          :charge => charge,
          :parent_ion_mass => spec.parent_ion_mass(charge),
          :title => "#{spec.sequence} (#{series.join(', ')})"
        }
      end
      
      # Returns a Mascot::Spectrum for the peptide.
      def spectrum(peptide)
        Mascot::Spectrum.new(peptide, nterm, cterm)
      end
    end
  end
end