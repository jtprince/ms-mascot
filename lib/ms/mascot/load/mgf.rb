require 'tap/load'
require 'ms/mascot/mgf/archive'

module Ms
  module Mascot
    module Load
      
      # :startdoc::manifest loads entries from an mgf file
      #
      # Load entries from an mgf file.  A selector may be specified to select
      # only a subset of entries; by default all entries in the mgf file are
      # returned.
      #
      #   % tap run -- mgf/load --select 1 < MGF_FILE
      #   % tap run -- mgf/load --select 1..10 < MGF_FILE
      #
      # Entries are always returned as an array, even when the selecton is
      # for a single entry.
      #
      class Mgf < Tap::Load
        Archive = Ms::Mascot::Mgf::Archive
        
        config :select, nil do |input|    # An array selector for entries
          if input.kind_of?(String)
            input = "!ruby/range #{input}" if input =~ /\.{2,3}/
            input = YAML.load(input)
          end
          c.validate(input, [nil, Integer, Range, Array])
        end
        
        def open_io(input)
          if input.kind_of?(String)
            Archive.open(input) {|io| yield(io) }
          else
            super(input) do |io|
              arc = Archive.new(io)
              result = yield(arc)
              arc.close
              result
            end
          end
        end
        
        def load(arc)
          case select
          when Array then arc[*select]
          when nil then arc.to_a
          else arc[select]
          end
        end
      end
    end
  end
end