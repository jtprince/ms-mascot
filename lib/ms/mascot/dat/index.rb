require 'ms/mascot/dat/section'

class Ms::Mascot::Dat::Index < Ms::Mascot::Dat::Section
  
  def nqueries
    @nqueries ||= data.keys.select {|key| key =~ /query/ }.length
  end


  def query(index)
    query_key = "query#{index}"
    data.each_pair do |key, value|
      return value if key == query_key
    end
    nil
  end

  # returns all query sections
  def queries
    data.keys.grep( /^query(\d+)$/o )
  end

end
