require 'strscan'

module Ms
  module Mascot
    class Dat
      
      # Represents a 'section' section of a dat file, formatted like this:
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
        
        # A format string used to format parameters as a string.
        TO_S_FORMAT = "%s=%s\n"

        def section_name
          @section_name ||= self.to_s.split('::').last.downcase
        end
              
        class << self

          # Parses a new instance from str.  Section after then content-type
          # declaration are parsed into the parameters hash.  Section follow
          # a simple "key=value\n" pattern.
          def parse(str, sec_name=nil, dat=nil)
            @section_name = sec_name ? sec_name : section_name
            params = {}
            scanner = StringScanner.new(str)
            
            # scan each pair.
            while key = scanner.scan(/[^=]+/)
              scanner.skip(/\=/)
              params[key] = scanner.scan(/[^\n]*/)
              scanner.skip(/\n/)
            end
            
            new(params, @section_name, dat)
          end
          
        end
        
        # A hash of data in self.
        attr_reader :data
        
        # The class section_name.
        attr_reader :section_name
        
        def initialize(data={}, name=self.class.section_name, dat=nil)
          @section_name = name 
          @data = data
          @dat = dat
        end

        # Formats self as a string with the content-type header.
        # use :header => false to prevent this
        def to_s(opts={})
          string = ""
          opts = {:header => true}.merge(opts)
          if opts[:header]
            string << "\n\nContent-Type: application/x-Mascot; name=\"#{section_name}\"\n\n"
          end
          string << (data.to_a.collect {|entry| self.class::TO_S_FORMAT % entry}.join)
        end
      end
    end
  end
end
