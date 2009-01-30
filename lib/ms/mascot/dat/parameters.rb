require 'strscan'

module Ms
  module Mascot
    module Dat
      
      # Represents a 'parameters' section of a dat file, formatted like this:
      #
      #   Content-Type: application/x-Mascot; name="parameters"
      #   
      #   LICENSE=Licensed to: Matrix Science Internal use only - Frill, (4 processors).
      #   MP=
      #   NM=
      #   COM=Peptide Mass Fingerprint Example
      #   IATOL=
      #   ...
      #
      # Example from mascot data F981122.dat
      class Parameters
        class << self
          
          # Parses a new instance from str.  Parameters after then content-type
          # declaration are parsed into the parameters hash.  Parameters follow
          # a simple "key=value\n" pattern, and may be have the key quoted like
          # "\"key\"=value\n".
          def parse(str)
            params = {}
            scanner = StringScanner.new(str)
      
            # skip whitespace and content type declaration
            scanner.scan(/\s*Content-Type:.*?\n\s*/)
      
            # scan each pair.
            while key = scanner.scan(/[^=]+"?/)
              scanner.skip(/"?=/)
              params[key] = scanner.scan(/[^\n]*/)
              scanner.skip(/\n/)
            end
      
            new(params)
          end
          
          # Returns the name of the section represented by this class.  Section
          # names are by default the downcase, unnested class name, for
          # example:
          #
          #   Ms::Mascot::Dat::Parameters.section_name  # => "parameters"
          #
          def section_name
            @section_name ||= to_s.split('::').last.downcase
          end
        end
        
        # A format string used to format parameters as a string.  By default
        # TO_S_FORMAT reflects the "key=value\n" syntax where key is not
        # quoted.
        TO_S_FORMAT = "%s=%s\n"
        
        # A hash of parameters in self.
        attr_reader :parameters
  
        def initialize(parameters={})
          @parameters = parameters
        end
  
        # The class section_name.
        def section_name
          self.class.section_name
        end
        
        # Formats self as a string with the content-type header.
        def to_s
          %Q{

Content-Type: application/x-Mascot; name="#{section_name}"

#{parameters.to_a.collect {|entry| TO_S_FORMAT % entry}.join}}
        end
      end
    end
  end
end
