require 'tap/http/submit'

module Ms
  module Mascot
    # :startdoc::manifest exports results from a search
    class Export < Tap::Http::Submit
      MASCOT_SWITCH = lambda do |input|
        input = case input
        when true, 1, '1', /true/i   then '1'
        when false, 0, '0', /false/i then '0'
        else input
        end
        
        c.validate(input, ['1', '0'])
      end
      DEFAULT_ATTRIBUTES[MASCOT_SWITCH] = {:type => :switch}
      
      # The MatrixScience public search site
      config :uri, "http://www.matrixscience.com/cgi/export_dat_2.pl"

      # Parameters for a typical export
      nest :params do
        config "pep_expect", "1", &MASCOT_SWITCH
        config "prot_mass", "1", &MASCOT_SWITCH
        config "protein_master", "1", &MASCOT_SWITCH
        config "_server_mudpit_switch", 0.000000001, &c.num
        config "pep_exp_mz", "1", &MASCOT_SWITCH
        config "do_export", "1", &MASCOT_SWITCH
        config "pep_delta", "1", &MASCOT_SWITCH
        config "export_format", "XML", &c.string
        config "prot_acc", "1", &MASCOT_SWITCH
        config "pep_score", "1", &MASCOT_SWITCH
        config "show_format", "1", &MASCOT_SWITCH
        config "_showsubsets", "0", &MASCOT_SWITCH
        config "_show_decoy_report", ""
        config "pep_scan_title", "1", &MASCOT_SWITCH
        config "pep_miss", "1", &MASCOT_SWITCH
        config "pep_calc_mr", "1", &MASCOT_SWITCH
        config "pep_exp_mr", "1", &MASCOT_SWITCH
        config "prot_score", "1", &MASCOT_SWITCH
        config "pep_query", "1", &MASCOT_SWITCH
        config "peptide_master", "1", &MASCOT_SWITCH
        config "prot_matches", "1", &MASCOT_SWITCH
        config "_onlyerrortolerant", ""
        config "_showallfromerrortolerant", ""
        config "prot_hit_num", "1", &MASCOT_SWITCH
        config "search_master", "1", &MASCOT_SWITCH
        config "_sigthreshold", 0.05, &c.num
        config "show_params", "1", &MASCOT_SWITCH
        config "show_mods", "1", &MASCOT_SWITCH
        config "show_header", "1", &MASCOT_SWITCH
        config "pep_isbold", "1", &MASCOT_SWITCH
        config "pep_seq", "1", &MASCOT_SWITCH
        config "pep_exp_z", "1", &MASCOT_SWITCH
        config "prot_desc", "1", &MASCOT_SWITCH
        config "_ignoreionsscorebelow", "0", &MASCOT_SWITCH
        config "REPORT", "AUTO", &c.string
        config "pep_rank", "1", &MASCOT_SWITCH
        config "pep_var_mod", "1", &MASCOT_SWITCH
        config "_noerrortolerant", ""
      end
      
      def process(result_filepath)
        params = config[:params].to_hash
        params['file'] = result_filepath
      
        # submit request
        super(
          :request_method => 'GET',
          :uri => uri,
          :params => params
        )
      end
    end 
  end
end