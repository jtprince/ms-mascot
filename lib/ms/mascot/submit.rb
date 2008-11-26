require 'tap/http/dispatch'

module Ms
  module Mascot
    # Ms::Mascot::Submit::manifest submits an mgf file 
    
    # Submit Documentation
    class Submit < Tap::Http::Dispatch

      def process(*mgf_files)
        # generate request hashes for the mgf files using the
        # configured parameters
        requests = mgf_files.collect do |mgf_file|
          file = {'Content-Type' => 'application/octet-stream', 'Filename' => mgf_file}  
          {:params => params.merge(:FILE => file)}
        end
        
        super(*requests)
      end
    end 
  end
end