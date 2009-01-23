
module Ms; end
module Ms::Mascot; end
class Ms::Mascot::Dat; end


## still thinking about
class Ms::Mascot::Dat::Query < Hash
  %w(title charge mass_min mass_max int_min int_max num_vals num_used1 Ions1).each do |s|
    define_method(s.downcase.to_sym) do 
      self[s]
    end
  end

  ##### implement casting??
  
  def initialize(str)
    Dat::str_to_hash(str, self)
  end

end


