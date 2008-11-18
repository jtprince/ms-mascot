require 'ms/in_silico/fragment'
require 'ms/mascot/spectrum'

module Ms
  module Mascot
  
    # Ms::Mascot::Fragment::manifest calculates a theoretical Mascot ms/ms spectrum
    #
    # Calculates the parent ion mass and theoretical ms/ms spectrum for a peptide
    # sequence.  Configurations allow the specification of one or more
    # fragmentation series to include, as well as charge, and intensity.
    # 
    #   % rap fragment TVQQEL --+ dump --no-audit
    #   # date: 2008-09-15 14:37:55
    #   ---
    #   ms/mascot/fragment (:...:):
    #   - - 717.3777467
    #     - - 102.054955
    #       - 132.1019047
    #       - 201.123369
    #       - 261.1444977
    #       - 329.181947
    #       - 389.2030757
    #       - 457.240525
    #       - 517.2616537
    #       - 586.283118
    #       - 616.3300677
    # 
    # In the output, the parent ion mass is given first, followed by an array of
    # the sorted fragmentation data.
    class Fragment < InSilico::Fragment

      def spectrum(peptide)
        Mascot::Spectrum.new(peptide, nterm, cterm)
      end
      
    end
  end
end