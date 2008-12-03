require 'tap/http/dispatch'

module Ms
  module Mascot
    # :startdoc::manifest submits an mgf file
    # UNDER CONSTRUCTION
    class Submit < Tap::Http::Dispatch
      RESULT_REGEXP = /<A HREF="..\/cgi\/master_results.pl\?file=(.*?\.dat)">/im
      ERROR_REGEXP = /<BR>The following error has occured getting your search details:<BR>(.*?)<BR>/im
      MISTAKE_REGEXP = /<BR>Sorry, your search could not be performed due to the following mistake entering data.<BR>(.*?)<BR>/im
      
      def process(*mgf_files)
        # generate request hashes for the mgf files using the
        # configured parameters
        requests = mgf_files.collect do |mgf_file|
          file = {'Content-Type' => 'application/octet-stream', 'Filename' => mgf_file}  
          {:params => params.merge("FILE" => file)}
        end

        super(*requests)
      end
      
      # Hook for processing a response.  By default process_response 
      # simply logs the response message and returns the response. 
      def process_response(res)
        case res.body
        when RESULT_REGEXP 
          log(res.message, $1)
          $1
          
        when ERROR_REGEXP
          raise ResponseError, "error: #{$1.strip}"
        when MISTAKE_REGEXP 
          raise ResponseError, "mistake: #{$1.strip}"
        else 
          raise ResponseError, "unknown error:\n#{res.body}"
        end
      end
    end 
  end
end