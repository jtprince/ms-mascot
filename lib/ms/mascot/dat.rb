require 'ms/mascot/dat/archive'

module Ms
  module Mascot
    module Dat
      class << self
        # gives the block the opened Ms::Mascot::Dat::Archive object
        def open(filename, &block)
          Archive.open(filename, &block)
        end

        # returns an Ms::Mascot::Mgf::Archive object, or if provided a filename,
        # will write to filename instead.
        # Yields the Archive object.
        #
        # example of writing spetra to "out.mgf":
        #
        #     dat.to_mgf("out.mgf") do |mgf|
        #       # use the Query#to_mgf method:
        #       mgf << query.to_mgf(peptide_hit)
        #
        #       # create your own entry object
        #       mgf << Ms::Mascot::Dat::Mgf::Entry.new(header, data)
        #
        #       # push on the strings
        #       mgf << "BEGIN IONS"
        #       mgf << "TITLE=mytitle"
        #       # ... the rest of the info ...
        #       mgf << "END IONS"
        #     end
        def to_mgf(filename=nil)
          mgf = Ms::Mascot::Mgf::Archive.new
          yield mgf
          if filename
            mgf.close(filename)
          else
            mgf
          end
        end
      end
    end
  end
end


