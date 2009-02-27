require 'tap/http/submit'

module Ms
  module Mascot
    # :startdoc::manifest submits a PMF or MS/MS search to Mascot
    #
    # Submits a search request to Mascot using the mgf file and the search
    # parameters in a static config file.  Correctly formatting search
    # config file is technical since it must contain the correct fields for
    # Submit to recreate a Mascot HTTP search request.
    #
    # The easiest way to capture search parameters in the correct format is
    # to use TapHttpFrom the command line, invoke:
    #
    #   % tap server
    #
    # Then visit 'http://localhost:8080/capture/tutorial' in a browser and
    # apply the capture procedure to the Mascot search page.  Once you have
    # the .yml config file, use this command to submit a search.
    #
    #   % rap submit <mgf_file> --config <config_file> --: dump
    #
    # A convenient aspect of this setup is that you can capure parameters
    # once, then re-use them for a number of mgf files.
    #
    # Note that the default Submit configuration uses parameters are typical
    # for MS/MS searching of a human sample digested with trypsin.  These
    # values MUST be overridden and are only provided as a template (for
    # those that want the adventure of manually making a config file).
    #
    class Submit < Tap::Http::Submit
      
      # The MatrixScience public search site
      DEFAULT_URI = "http://www.matrixscience.com/cgi/nph-mascot.exe?1"
      
      # Parameters for MS/MS searching of a human sample digested with trypsin.
      DEFAULT_PARAMS = {
        "ErrTolRepeat"=>"0",
        "PFA"=>"1",
        "INSTRUMENT"=>"Default",
        "REPTYPE"=>"peptide",
        "COM"=>"Search Title",
        "FORMAT"=>"Mascot generic",
        "PEAK"=>"AUTO",
        "CHARGE"=>"2+",
        "INTERMEDIATE"=>"",
        "SHOWALLMODS"=>"",
        "PRECURSOR"=>"",
        "USERNAME"=>"Name",
        "TOLU"=>"ppm",
        "USEREMAIL"=>"email@email.com",
        "CLE"=>"Trypsin",
        "TOL"=>"100",
        "ITOLU"=>"Da",
        "QUANTITATION"=>"None",
        "SEARCH"=>"MIS",
        "DB"=>"SwissProt",
        "PEP_ISOTOPE_ERROR"=>"0",
        "ITOL"=>"0.6",
        "FORMVER"=>"1.01",
        "IT_MODS"=> [
          "Acetyl (Protein N-term)",
          "Gln->pyro-Glu (N-term Q)",
          "Oxidation (M)"],
        "MASS"=>"Monoisotopic",
        "REPORT"=>"AUTO",
        "TAXONOMY"=>". . . . . . . . . . . . . . . . Homo sapiens (human)"
      }
      
      # Typical headers for an MS/MS search.
      DEFAULT_HEADERS = {
       "Keep-Alive"=>"300",
       "Accept-Encoding"=>"gzip,deflate",
       "Accept-Language"=>"en-us,en;q=0.5",
       "Content-Type"=> "multipart/form-data; boundary=---------------------------168072824752491622650073",
       "Accept-Charset"=>"ISO-8859-1,utf-8;q=0.7,*;q=0.7",
       "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
       "Connection"=>"keep-alive"
      }
      
      # Matches a successful search response.  After the match:
      #
      #  $1:: the result file
      SUCCESS_REGEXP = /<A HREF="\.\.\/cgi\/master_results\.pl\?file=(.*?)">Click here to see Search Report<\/A>/
      
      # Matches a failure response.  After the match:
      #
      #  $1:: the failure message
      FAILURE_REGEXP = /<BR>(.*)/m
      
      config :uri, DEFAULT_URI                           # The uri of the mascot search site
      config :headers, DEFAULT_HEADERS, &c.hash          # a hash of request headers
      config :params, DEFAULT_PARAMS, &c.hash            # a hash of query parameters
      config :request_method, 'POST'                     # the request method (get or post)
      config :version, 1.1                               # the HTTP version
      config :redirection_limit, nil, &c.integer_or_nil  # the redirection limit for the request
      
      def process(mgf_file)
        
        # duplicate the configurations
        request = {}
        config.each_pair do |key, value|
          request[key] = value.kind_of?(Hash) ? value.dup : value
        end
        
        # set filename for upload
        file = request[:params]['FILE'] ||= {}
        file['Filename'] = mgf_file
        file['Content-Type'] = 'application/octet-stream'
        file.delete('Content')
        
        # submit request
        parse_response_body super(request)
      end
      
      # Processes the response body.  Returns the result file if the body
      # indicates a success, or nil if the body indicates a failure.
      def parse_response_body(body)
        case body
        when SUCCESS_REGEXP
          log :success, $1
          $1
        when FAILURE_REGEXP 
          log :failure, $1.gsub("<BR>", "\n")
          nil
        else 
          raise "unparseable response: #{body}"
        end
      end
    end
  end
end