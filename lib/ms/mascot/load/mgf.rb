require 'tap/tasks/load'
require 'ms/mascot/mgf/archive'

module Ms
  module Mascot
    module Load
      
      # :startdoc::task loads entries from an mgf file
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
      class Mgf < Tap::Tasks::Load
        Archive = Ms::Mascot::Mgf::Archive
        
        config :select, nil do |input|    # An array selector for entries
          if input.kind_of?(String)
            input = "!ruby/range #{input}" if input =~ /\.{2,3}/
            input = YAML.load(input)
          end
          c.validate(input, [nil, Integer, Range, Array])
        end
        
        nest :filter do
          config :title, nil, &c.regexp_or_nil
          config :charge, nil, &c.range_or_nil
          config :pepmass, nil, &c.range_or_nil
          config :n_ions, nil, &c.range_or_nil
          
          def ok?(entry)
            (!title   || entry.title =~ title) &&
            (!charge  || charge.include?(entry.charge)) &&
            (!pepmass || pepmass.include?(entry.pepmass)) &&
            (!n_ions  || n_ions.include?(entry.data.length))
          end
          
          def filter!(entries)
            return entries unless title || charge || pepmass || n_ions
            entries.select {|entry| ok?(entry) }
          end
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
          when Integer
            entry = arc[select]
            filter.ok?(entry) ? [entry] : []
          when Range
            filter.filter!(arc[select])
          when Array 
            filter.filter!(arc[*select])
          when nil 
            arc.select {|entry| filter.ok?(entry) }
          end
        end
      end
    end
  end
end