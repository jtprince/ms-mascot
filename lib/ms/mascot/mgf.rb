require 'ms/mascot/mgf/entry'
require 'ms/mascot/mgf/archive'

module Ms
  module Mascot
    module Mgf
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
            ar.each &block
          end
        end
      end
    end
  end
end
