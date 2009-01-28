# see the Dat[link:classes/Ms/Mascot/Dat.html] class for documentation

require 'ms/mascot/dat'
require 'cgi'

module Ms; end
module Ms::Mascot; end

class Ms::Mascot::Dat
  QUERY_HASH_KEYS = %w(title charge mass_min mass_max int_min int_max num_vals num_used1 Ions1)
  QUERY_ATTS = QUERY_HASH_KEYS.map do |v|
    if v == 'Ions1'
      v = 'ions1'
    end
    v.to_sym
  end
  # the query number
  QUERY_ATTS << :num
end

# The Query class
class Ms::Mascot::Dat::Query 
end

Ms::Mascot::Dat::Query = Struct.new( *(Ms::Mascot::Dat::QUERY_ATTS) )

class Ms::Mascot::Dat::Query
  CAST = {'charge' => :to_i, 'mass_min' => :to_f, 'mass_max' => :to_f, 'int_min' => :to_f, 'int_max' => :to_f, 'num_vals' => :to_i, 'num_used1' => :to_i } 

  alias_method :ions, :ions1
  alias_method :Ions1, :ions1

  class << self
    # returns a Query object from the dat query string with proper casting
    def from_string(string, num)
      hash = Ms::Mascot::Dat.str_to_hash(string)
      vals = Ms::Mascot::Dat::QUERY_HASH_KEYS[1...-1].map  do |k|
        hash[k].send(CAST[k])
      end
      # three special cases:
      vals.unshift( CGI.unescape(hash['title']) )
      vals.push( cast_ion_string(hash['Ions1']) )
      vals.push( num )
      self.new(*vals)
    end

    def cast_ion_string(string)
      string.split(',').map do |pair|
        pair.split(':').map {|v| v.to_f }
      end
    end

  end


end


