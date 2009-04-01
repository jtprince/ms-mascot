require 'tap/mechanize/request'
require 'ms/mascot/validation'

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
    class Submit < Tap::Mechanize::Request
      include Validation
      
      # Matches a successful search response.  After the match:
      #
      #  $1:: the result file
      SUCCESS_REGEXP = /<A HREF="\.\.\/cgi\/master_results\.pl\?file=(.*?)">Click here to see Search Report<\/A>/
      
      # Matches a failure response.  After the match:
      #
      #  $1:: the failure message
      FAILURE_REGEXP = /<BR>(.*)/m
      
      # The MatrixScience public search site
      config :uri, "http://www.matrixscience.com/cgi/nph-mascot.exe?1"  # The uri of the mascot search site
      
      # Parameters for MS/MS searching of a human sample digested with trypsin
      nest :params do                                          # The query parameters
        config "USERNAME", "Name",  &c.string
        config "USEREMAIL", '', &c.string
        config "COM", "Search Title",  &c.string
        config "INSTRUMENT", "Default", &c.string
        config "FORMAT", "Mascot generic",  &c.string
        config "CHARGE", "+2"
        config "TOLU", "ppm",  &c.string
        config "CLE", "Trypsin", &c.string
        config "TOL", 100, &c.num
        config "ITOLU", "Da", &c.string
        config "PFA", 1, &MASCOT_SWITCH
        config "DB", "SwissProt", &c.string
        config "ITOL", 0.6, &c.float
        config "IT_MODS", [
          "Acetyl (Protein N-term)",
          "Gln->pyro-Glu (N-term Q)",
          "Oxidation (M)"
        ], &c.list
        config "MASS", "Monoisotopic", &c.string
        config "REPORT", "AUTO", &c.string
        config "TAXONOMY", ". . . . . . . . . . . . . . . . Homo sapiens (human)", &c.string
        config "INTERMEDIATE", "",  &c.string
        config "PRECURSOR", "",  &c.string
        config "QUANTITATION", "None", &c.string
        config "PEP_ISOTOPE_ERROR", 0, &c.num
        config "SEARCH", "MIS", :type => :hidden
        config "PEAK", "AUTO", :type => :hidden
        config "SHOWALLMODS", "", :type => :hidden
        config "ErrTolRepeat", 0, :type => :hidden
        config "REPTYPE", "peptide", :type => :hidden
        config "FORMVER", 1.01, :type => :hidden
      end
      
      def process(mgf_file)
        File.open(mgf_file) do |io|
          # set filename for upload
          params = config[:params].to_hash
          params['FILE'] = io
        
          # submit request
          page = super(
            :request_method => 'POST',
            :uri => uri,
            :params => params
          )
          
          parse_response_body(page.body)
        end
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