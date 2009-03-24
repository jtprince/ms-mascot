require 'ms/mascot/mgf/entry'
require 'ms/mascot/mgf/archive'
require 'set'

module Ms
  module Mascot
    module Mgf
      # see http://www.matrixscience.com/help/data_file_help.html
      VALID_LOCAL_HEADERS = Set.new(%w(CHARGE COMP ETAG INSTRUMENT IT_MODS PEPMASS RTINSECONDS SCANS SEQ TAG TITLE TOL TOLU))
      VALID_GLOBAL_HEADERS = Set.new(%w(ACCESSION CHARGE CLE COM CUTOUT DB DECOY ERRORTOLERANT FORMAT FRAMES INSTRUMENT IT_MODS ITOL ITOLU MASS MODS PEP_ISOTOPE_ERROR PFA PRECURSOR QUANTITATION REPORT REPTYPE SEARCH SEG TAXONOMY TOL TOLU USER00 USER01 USER02 USER03 USER04 USER05 USER06 USER07 USER08 USER09 USER10 USER11 USER12 USEREMAIL USERNAME))

      class << self
        # Opens the file and yields an array of entries (well, the array is
        # actually an Ms::Mascot::Mgf::Archive object that acts like an array
        # but leaves data on disk until needed)
        #
        #   Ms::Mascot::Mgf.open("file.mgf") do |ar|
        #     entry5 = ar[4]  # -> 5th entry
        #     entry5.pepmass  # -> peptide mass
        #     entry5.data     # -> array of arrays
        #   end
        def open(file, &block)
          File.open(file) do |io|
            a = Archive.new(io)
            a.reindex
            block.call(a)
            a.close
          end
        end

        # returns each entry in the mgf file, like IO.foreach
        def foreach(file, &block)
          open(file) do |ar|
            ar.each( &block )
          end
        end

        # yields an Ms::Mascot::Mgf::Archive object and writes the data to
        # outfile.
        #
        # example of writing spetra to "out.mgf":
        #
        #     Ms::Mascot::Mgf.write("out.mgf") do |mgf|
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
        def write(outfile)
          mgf = Archive.new
          yield mgf
          mgf.close(outfile, nil, true)
        end

      end # end module methods
    end
  end
end
