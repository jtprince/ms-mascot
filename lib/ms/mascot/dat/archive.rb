require 'external'

module Ms
  module Mascot
    module Dat
      
      # A hash of (section_name, SectionClass) pairs mapping section names
      # to section class.  Initially SectionClass may be a require path; if
      # so the path is required and the class looked up like:
      #
      #   Ms::Mascot::Dat.const_get(section_name.capitalize)
      #
      # Such that 'header' is mapped to Ms::Mascot::Dat::Header.
      CONTENT_TYPE_CLASSES = {}
      
      # currently unimplemented: unimod enzyme taxonomy mixture quantitation
      %w{header index masses parameters peptides proteins summary query
      }.each do |section_name|
        CONTENT_TYPE_CLASSES[section_name] = "ms/mascot/dat/#{section_name}"
      end 
      
      # Provides access to a Mascot dat file.
      class Archive < ExternalArchive
        include Dat

        # Parsing & Archive functions
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
          
          # Parses a mascot-style content type declaration.  This method uses
          # a simple regexp and is very brittle, but it works for all known
          # dat files.
          def parse_content_type(str)
            unless str =~ /^Content-Type: (.*?); name=\"(.*)\"/
              raise "unparseable content-type declaration: #{str.inspect}"
            end
            
            {:content_type => $1, :section_name => $2}
          end
          
          # Resolves a content type class from a hash of metadata like:
          #
          #   metadata = {
          #     :content_type => 'application/x-Mascot',
          #     :section_name => 'header'
          #   }
          #   Dat.content_type_class(metadata)   # => Ms::Mascot::Dat::Header
          #
          # Raises an error if the content type is not 'application/x-Mascot'
          # or if the name is not registered in CONTENT_TYPE_CLASSES.
          def content_type_class(metadata)
            unless metadata[:content_type] == 'application/x-Mascot'
              raise "unknown content_type: #{metadata.inspect}"
            end
            
            name = metadata[:section_name]
            name = 'query' if name =~ /^query(\d+)$/
            case const = CONTENT_TYPE_CLASSES[name]
            when String
              require const
              CONTENT_TYPE_CLASSES[name] = Dat.const_get(name.capitalize)
            else
              const
            end
          end
        end
        
        include Utils
        
        # A hash of metadata associated with this dat file.
        attr_reader :metadata
        
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
            # :blksize => 8388608,  # default in ExternalArchive
            :blksize => 33_554_432,  # quadrupled the blksize
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
            ctc.parse(str, self)
          else
            str
          end
        end
        
        # The section names corresponding to each entry in self.
        #
        # Normally section names are lazily parsed from the Content-Type header
        # of an entry as needed.  If resolve is true, all section names are
        # parsed and then returned; otherwise section_names may return a
        # partially-filled array.
        def section_names(resolve=true)
          resolve_sections if resolve
          @section_names
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

        # Returns the section name for the entry at index.
        def section_name(index)
          # all sections must be resolved for negative indicies to
          # work correctly (since otherwise @section_names may not
          # have the same length as self)
          resolve_sections if index < 0
          @section_names[index] ||= parse_section_name(index)
        end
        
        # Returns the number of queries registered in self.
        def nqueries
          @nqueries ||= section_names.select {|name| name =~ /query/ }.length
        end
        
        # Yields each query to the block.
        def each_query
          1.upto(nqueries) do |n|
            yield(query(n))
          end
        end

        # Returns the specified query. 
        def query(num)
          if si = section_index("query#{num}")
            self[si]
          else
            nil
          end
        end

        # by default, yields the top PeptideHit object per query
        # opts may be:
        #     :by => :top
        #       :top     top ranked hit (default)
        #       :groups  an array of hits
        #       :all     each peptide hit (all ranks)
        #
        #     :yield_nil => true 
        #       true     returns nil when a query had no peptide hit (default)
        #       false    this hit (or group) is not yielded
        #     :with_query => false
        #       false    just returns peptide hits/groups (default) 
        #       true     yields the peptide_hit/group and associated query
        def each_peptide_hit(opts={})
          defaults = { :by => :top, :yield_nil => true, :with_query => false }
          (by, yield_nil, with_query) = defaults.merge(opts).values_at(:by, :yield_nil, :with_query)

          peptides = section('peptides')
          1.upto(nqueries) do |n|
            case by
            when :top
              hit = peptides.peptide_hit(n)
              unless !yield_nil && hit.nil?
                if with_query
                  yield hit, query(n)
                else
                  yield hit
                end
              end
            when :groups
              group = peptides.peptide_hits(n)
              group.shift # remove the 0 index
              unless !yield_nil && group.first.nil?
                if with_query
                  yield group, query(n)
                else
                  yield group
                end
              end
            when :all

              group = peptides.peptide_hits(n)
              group.shift # remove the 0 index
              unless !yield_nil && group.first.nil?
                # need to return the nil hit if we are yielding nils:
                if group.first.nil?
                  if with_query
                    yield nil, query(n)
                  else
                    yield nil
                  end
                end
                group.each do |pep_hit|
                  if with_query
                    yield pep_hit, query(n)
                  else
                    yield pep_hit
                  end
                end
              end
            end
          end
        end
        
        private
        
        # resolves each section
        def resolve_sections # :nodoc:
          (@section_names.length).upto(length - 1) do |index| 
            section_name(index)
          end
        end
        
        # helper to go to the entry at index and parse the section name
        def parse_section_name(index) # :nodoc:
          return nil unless index = io_index[index]
          io.pos = index[0] + 1
          parse_content_type(io.readline)[:section_name]
        end

      end # Archive
    end  # Dat
  end  # Mascot
end  # Ms
