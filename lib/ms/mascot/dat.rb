require 'ms/mascot/dat/archive'

module Ms
  module Mascot
    module Dat
      
      class << self
        def open(filename, &block)
          File.open(filename) do |io|
            ar = Archive.new(io)
            ar.reindex
            block.call(ar)
          end
        end
      end

      def each_query(&block)
        self.section('index').queries.each do |key|
          block.call( self.section(key) )
        end
      end

      # returns array of names of the sections
      def sections
        self.section('index').data.keys
      end

      class Archive
        include Dat
      end
    end
  end
end


