require 'tap/http/dispatch'

module Ms
  module Mascot
    # Ms::Mascot::Export::manifest <replace with manifest summary>
    # <replace with command line description>
    
    # Export Documentation
    class Export < Tap::Http::Dispatch
    
      def process(*mascot_files)
        # generate request hashes for the mgf files using the
        # configured parameters
        requests = mascot_files.collect do |mascot_file| 
          {:params => params.merge("file" => mascot_file)}
        end

        super(*requests)
      end
    end 
  end
end