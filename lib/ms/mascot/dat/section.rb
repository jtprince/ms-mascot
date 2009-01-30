require 'strscan'

module Ms
  module Mascot
    module Dat
      
      # Represents a 'section' section of a dat file, formatted like this:
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
      class Section
        
        # Matches a content-type declaration plus any preceding/following
        # whitespace.  The section name is matched in slot 0.
        CONTENT_TYPE_REGEXP = /\s*Content-Type: application\/x-Mascot; name=\"(.*?)\"\n\s*/
        
        # A format string used to format parameters as a string.
        TO_S_FORMAT = "%s=%s\n"
              
        class << self
          
          # Parses a new instance from str.  Section after then content-type
          # declaration are parsed into the parameters hash.  Section follow
          # a simple "key=value\n" pattern.
          def parse(str)
            params = {}
            scanner = StringScanner.new(str)
            
            # skip whitespace and content type declaration
            unless scanner.scan(CONTENT_TYPE_REGEXP)
              raise "unknown content type: #{content_type}"
            end
            section_name = scanner[0]
            
            # scan each pair.
            while key = scanner.scan(/[^=]+/)
              scanner.skip(/=/)
              params[key] = scanner.scan(/[^\n]*/)
              scanner.skip(/\n/)
            end
            
            new(params, section_name)
          end
          
          # Returns the name of the section represented by this class.  Section
          # names are by default the downcase, unnested class name, for
          # example:
          #
          #   Ms::Mascot::Dat::Section.section_name  # => "parameters"
          #
          def section_name
            @section_name ||= to_s.split('::').last.downcase
          end
        end
        
        # A hash of data in self.
        attr_reader :data
        
        # The class section_name.
        attr_reader :section_name
        
        def initialize(data={}, section_name=self.class.section_name)
          @data = data
          @section_name = section_name
        end
        
        # Formats self as a string with the content-type header.
        def to_s
          %Q{

Content-Type: application/x-Mascot; name="#{section_name}"

#{data.to_a.collect {|entry| TO_S_FORMAT % entry}.join}}
        end
      end
    end
  end
end
