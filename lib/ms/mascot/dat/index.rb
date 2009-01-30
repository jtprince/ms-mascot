require 'ms/mascot/dat/section'

class Ms::Mascot::Dat::Index < Ms::Mascot::Dat::Section
  
  def nqueries
    @nqueries ||= parameters.keys.select {|key| key =~ /query/ }.length
  end
  
  def query(index)
    query_key = "query#{index}"
    parameters.each_pair do |key, value|
      return value if key == query_key
    end
    nil
  end
end