
require 'ms/mascot/dat/query'

module Ms; end
module Ms::Mascot; end

# The interface to the Dat file is not entirely complete.  Stable interfaces
# include: query, parameters, header, masses, index, and enzyme
#
#    Dat.open(filename) do |dat|
#      dat.parameters   # -> hash of parameters
#      dat.header       # -> hash of header parameters
#      # other hases are masses and index; keys and values are all strings
#      
#      dat.query(3)     # -> query number 3
#      dat.query(0)     # -> nil  since they start at 1
#      dat.each_query {|q| ... do stuff with each query ... }
#    end
#
# Ms::Mascot::Dat::Query is a struct rather than class (so rdoc won't generate
# class documentaton for it).  Here is how to use a query object:
#
#    query.title    # -> html unescaped String
#    query.charge   # -> Integer
#    query.mass_min # -> Float
#    ...etc...
#
#    # structs can be accessed and set like an object, hash, or array, eg:
#    query.title == query['title'] == query[0]
#
#    # convenient aliases for ions1:
#    query.Ions1 == query.ions1 == query.ions
#
#    query.num     # -> the query number (not a dat file indegeneous attribute)
#
#    # NOTE: Dat::QUERY_HASH_KEYS indicates the indexing order (except :num
#    which is after Ions1) if you want array like access.
#
class Ms::Mascot::Dat
  MascotSection_re = /Content-Type: application\/x-Mascot; name="(\w+)"/o
  QueryMatch_re = /query(\d+)/o
  ParamMatch_re = /(\w+)=(.*)/o

  # what to do with enzyme ??
  HASHES = %w(parameters masses header index)

  class << self

    # The block returns a new Dat object.  This is lazy io: sections of the
    # files are only read from disk when the method is called for that
    # section.  All sections are guaranteed to have an accompanying method.
    # Some
    def open(filename, &block)
      File.open(filename) do |io|
        obj = self.new(io)
        create_index_methods(obj, obj.byte_index.keys )
        block.call(obj)
      end
    end

    def create_index_methods(obj, names) # :nodoc:
      names.each do |key|
        unless obj.respond_to? key
          method_string = 
            if HASHES.include? key
              "def #{key}()
                 self.class.str_to_hash( read_section(byte_index['#{key}']) ) 
               end"
            else
              "def #{key}()
                 read_section(byte_index['#{key}'])
               end"
            end
          obj.instance_eval method_string
        end
      end
    end

    # returns {'<type>' => [start_byte, num_bytes]}
    # type is one of: parameters, masses, unimod, enzyme, header, summary,
    # decoy_summary, peptides, proteins, index  (maybe more of
    # these, but it will get them too)
    # NOTE: the key 'query' returns an array indexed on query number
    #   eg: index['parameters']  # -> [70, 211]
    #       index['query']       # -> [[3001,70], [3071,80], [3152,75]...]
    #       index['query'][75]   # -> [8542,93] # start & length for query 75
    # REWINDS the io
    def byte_index(io)  # :nodoc:
      ar = []
      # get the boundary size and advance io to start
      io.gets
      bound_size = io.gets.match(/boundary=(.*)/)[1].size + 4

      ar = []
      io.each("\n") do |line|
        if md = MascotSection_re.match(line) 
          ar << [md[1], line.size, io.pos]
        end
      end
      hash = {}
      # add a placeholder in order to process the last one
      ar << ['--placeholder--', 2, io.pos]
      query_ar = []
      ar.enum_cons(2) do |a,b|
        key = a.first
        value = [a.last+1, (b.last - a.last) - (bound_size + b[1])]
        if md = QueryMatch_re.match(key)
          query_ar[md[1].to_i] = value
        else
          hash[key] = value
        end
      end
      hash['query'] = query_ar if query_ar.size > 0
      io.rewind
      hash
    end

    # transforms dat parameters into a hash, should work on most sections
    # except the unimod xml
    def str_to_hash(string, hash={})   # :nodoc:
      string.each("\n") do |line|
        if md = ParamMatch_re.match(line)
          hash[md[1]] = md[2]
        else
          if md = /(\w)/.match(line)
            hash[md[1]] = ""
          end
        end
      end
      hash
    end
  end  # end class methods

  # the io object given to the new method
  attr_reader :io

  # (mainly for internal use), a hash keyed by dat section with values that
  # are each a little array: [start_byte, num_bytes]
  attr_reader :byte_index

  # use Dat.open(filename, &block) rather than this.
  def initialize(io) # :nodoc:
    @io = io
    @byte_index = self.class.byte_index(io)
    @query_index_ar = @byte_index['query']
  end
  
  def each_query(&block)
    @query_index_ar.each_with_index do |ar, i|
      if ar
        block.call( Ms::Mascot::Dat::Query.from_string( read_section(ar), i ) )
      end
    end
  end

  # these are retrieved by the query number (which typically starts at 1,
  # rather than 0)
  #     query(0)   # -> nil
  #     query(1)   # -> (bona fide query object)
  def query(num)
    ind_ar = @query_index_ar[num]
    if ind_ar 
      Ms::Mascot::Dat::Query.from_string( read_section(ind_ar), num )
    else ; nil
    end
  end

  # Returns an array of query objects
  # Takes an array (or enumerable) of query numbers
  # if nil returns all queries (the default)
  #
  #   Dat.open(file) do |dat|
  #     dat.queries   # -> all queries (use each_query if memory is issue)
  #     dat.queries([1,4,5])  # -> just query 1, 4, and 5
  #   end
  def queries(array=nil)
    # would be nice to allow range input, but it would be really tricky to get
    # the indices back from the range input which are necessary for setting
    # the query.num attribut.
    if array.nil?
      qrs = []
      self.each_query {|qr| qrs << qr }
      qrs
    else
      array.map do |num| 
        ind = @query_index_ar[num]
        if ind
          Ms::Mascot::Dat::Query.from_string( read_section(ind), num)
        else ;nil
        end
      end
    end
  end

  # Returns a string
  # takes an ar: [pos, length]
  def read_section(ar) # :nodoc:
    @io.pos = ar.first
    @io.read(ar.last)
  end

end
