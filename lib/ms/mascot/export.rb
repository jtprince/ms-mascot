require 'tap/http/submit'

module Ms
  module Mascot
    # :startdoc::manifest exports results from a search
    class Export < Tap::Http::Submit
    
      # The MatrixScience public search site
      DEFAULT_URI = "http://www.matrixscience.com/cgi/export_dat_2.pl"

      # Parameters for a typical export
      DEFAULT_PARAMS = {
        "pep_expect"=>"1",
        "prot_mass"=>"1",
        "protein_master"=>"1",
        "_server_mudpit_switch"=>"0.000000001",
        "pep_exp_mz"=>"1",
        "do_export"=>"1",
        "pep_delta"=>"1",
        "export_format"=>"XML",
        "prot_acc"=>"1",
        "pep_score"=>"1",
        "show_format"=>"1",
        "_showsubsets"=>"0",
        "_show_decoy_report"=>"",
        "pep_scan_title"=>"1",
        "pep_miss"=>"1",
        "pep_calc_mr"=>"1",
        "pep_exp_mr"=>"1",
        "prot_score"=>"1",
        "pep_query"=>"1",
        "peptide_master"=>"1",
        "prot_matches"=>"1",
        "_onlyerrortolerant"=>"",
        "_showallfromerrortolerant"=>"",
        "prot_hit_num"=>"1",
        "search_master"=>"1",
        "_sigthreshold"=>"0.05",
        "show_params"=>"1",
        "show_mods"=>"1",
        "show_header"=>"1",
        "pep_isbold"=>"1",
        "pep_seq"=>"1",
        "pep_exp_z"=>"1",
        "prot_desc"=>"1",
        "_ignoreionsscorebelow"=>"0",
        "REPORT"=>"AUTO",
        "pep_rank"=>"1",
        "pep_var_mod"=>"1",
        "_noerrortolerant"=>""
      }

      # Typical headers for an export
      DEFAULT_HEADERS = {
        "Keep-Alive"=>"300",
        "Accept-Encoding"=>"gzip,deflate",
        "Accept-Language"=>"en-us,en;q=0.5",
        "Content-Type"=> "multipart/form-data; boundary=---------------------------168072824752491622650073",
        "Accept-Charset"=>"ISO-8859-1,utf-8;q=0.7,*;q=0.7",
        "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Connection"=>"keep-alive"
      }
      
      config :uri, DEFAULT_URI                           # The uri of the mascot search site
      config :headers, DEFAULT_HEADERS, &c.hash          # a hash of request headers
      config :params, DEFAULT_PARAMS, &c.hash            # a hash of query parameters
      config :request_method, 'GET'                      # the request method (get or post)
      config :version, 1.1                               # the HTTP version
      config :redirection_limit, nil, &c.integer_or_nil  # the redirection limit for the request
      
      def process(result_filepath)
        # duplicate the configurations
        request = {}
        config.each_pair do |key, value|
          request[key] = value.kind_of?(Hash) ? value.dup : value
        end
        
        # set filename for export
        request[:params]['file'] = result_filepath
        
        super(request)
      end
    end 
  end
end