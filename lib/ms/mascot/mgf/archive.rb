require 'external'
require 'ms/mascot/mgf/entry'

module Ms
  module Mascot
    module Mgf

      # Provides array-like access to an mgf archival file.
      class Archive < ExternalArchive

        # Reindexes self to each mgf entry in io
        def reindex(&block)
          reindex_by_sep("BEGIN IONS", :entry_follows_sep => true, &block)
        end

        # Returns an Mgf::Entry initialized using str
        def str_to_entry(str)
          Entry.parse(str)
        end

      end
    end
  end
end