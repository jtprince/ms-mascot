require 'external'

module Ms
  module Mascot
    module Dat
      
      # Provides access to a Mascot dat file.
      class Archive < ExternalArchive
        module Utils
          module_function
          
          # Parses a hash of metadata (content_type, boundary, etc) from io.
          # parse_metadata does not reposition io.
          def parse_metadata(io)
            current_pos = io.pos
            io.rewind
            
            metadata = {}
            line = io.readline
            unless line =~ /MIME-Version: (\d+\.\d+) \(Generated by Mascot version (\d+\.\d+)\)/
              raise "could not parse mime-version or mascot-version: #{line}"
            end
            metadata[:mime_version] = $1
            metadata[:mascot_version] = $2
            
            line = io.readline
            unless line =~ /Content-Type: (.*?); boundary=(.*)/
              raise "could not parse content-type: #{line}"
            end
            metadata[:content_type] = $1
            metadata[:boundary] = $2
            
            io.pos = current_pos
            metadata
          end
          
          # Parses a mascot-style content type declaration.  This method is
          # very brittle, but works for all known dat files.
          def parse_content_type(str)
            unless str =~ /^Content-Type: (.*?); name=\"(.*)\"/
              raise "unparseable content-type declaration: #{str}"
            end
            
            {:content_type => $1, :name => $2}
          end
          
          # %w{parameters masses unimod enzyme taxonomy header summary mixture index peptides proteins quantitation}
          def content_type_class(metadata)
            unless metadata[:content_type] == 'application/x-Mascot'
              raise "unknown content_type: #{metadata.inspect}"
            end
            
            const_name = metadata[:name].camelize
            Dat.const_defined?(const_name) ? const_name : nil
          end
        end
        
        include Utils
        
        # A hash of metadata associated with this dat file.
        attr_reader :metadata
        
        # An array of section names associated with each entry in self.
        # Section names are determined dynamically when accessed through
        # the section_name method.
        attr_reader :section_names
        
        def initialize(io=nil, io_index=nil)
          super(io)
          @metadata = parse_metadata(io)
          @section_names = []
        end
        
        # The boundary separating sections, typically '--gc0p4Jq0M2Yt08jU534c0p'.
        def boundary
          "--#{metadata[:boundary]}"
        end
        
        # Reindexes self.
        def reindex(&block)
          @section_names.clear
          reindex_by_sep(boundary, 
            :entry_follows_sep => true, 
            :exclude_sep => true,
          &block)
          
          # remove the first and last entries, which contain
          # the metadata and indicate the end of the multipart 
          # form data.
          io_index.shift
          io_index.pop
           
          self
        end
        
        # Converts str into an entry according to the content type header
        # which should be present at the start of the string.
        def str_to_entry(str)
          if ctc = content_type_class(parse_content_type(str))
            ctc.parse(str)
          else
            str
          end
        end
        
        # Returns the entry for the named section.
        def section(name)
          self[section_index(name)]
        end
        
        # Returns the index of the named section.
        def section_index(name)
          0.upto(length - 1) do |index|
            return index if section_name(index) == name
          end
          nil
        end
        
        # Returns the section name for the entry at index.  Undetermined
        # section names are parsed from the entry's Content-Type header.
        def section_name(index)
          resolve_sections if index < 0
          @section_names[index] ||= parse_section_name(index)
        end
        
        # Resolves all sections.
        def resolve_sections
          (@section_names.length).upto(length - 1) do |index| 
            section_name(index)
          end
        end
        
        private
        
        # helper to go to the entry at index and parse the section name
        def parse_section_name(index) # :nodoc:
          return nil unless index = io_index[index]
          io.pos = index[0] + 1
          parse_content_type(io.readline)[:name]
        end
      end
    end
  end
end