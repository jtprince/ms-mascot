require 'ms/mascot/dat/section'

# Index maps section names to the line at which the multipart break (ex
# '--gc0p4Jq0M2Yt08jU534c0p') occurs.  Achive creates it's own index and
# does not make use of this section.
#
#   Content-Type: application/x-Mascot; name="index"
#   
#   parameters=4
#   masses=78
#   unimod=117
#   ...
#
# Index is a standard Section and simply defines methods for convenient
# access.  See Section for parsing details.
class Ms::Mascot::Dat::Index < Ms::Mascot::Dat::Section
  
  # Returns the number of queries registered in self.
  def nqueries
    @nqueries ||= data.keys.select {|key| key =~ /query/ }.length
  end
  
  # Returns the line at which the specified query begins.
  def query(index)
    query_key = "query#{index}"
    data.each_pair do |key, value|
      return value if key == query_key
    end
    nil
  end

  # Returns all query sections
  def queries
    data.keys.grep( /^query(\d+)$/o ).sort
  end
end
