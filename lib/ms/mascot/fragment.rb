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
    #   - - 717.377745628191
    #     - - 102.054954926291
    #       - 132.101905118891
    #       - 201.123368842491
    #       - 261.144498215091
    #       - 329.181946353891
    #       - 389.203075726491
    #       - 457.240523865291
    #       - 517.261653237891
    #       - 586.283116961491
    #       - 616.330067154091
    #       - 699.367180941891
    #       - 717.377745628191
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