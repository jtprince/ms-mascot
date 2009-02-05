require 'ms/mascot/dat/archive'

module Ms
  module Mascot
    module Dat
      class << self
        # gives the block the opened Ms::Mascot::Dat::Archive object
        def open(filename, &block)
          Archive.open(filename, &block)
        end
      end
    end
  end
end


