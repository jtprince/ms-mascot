
require 'ms/mascot/dat/query'

module Ms; end
module Ms::Mascot; end

class Ms::Mascot::Dat
  MascotSection_re = /Content-Type: application\/x-Mascot; name="(\w+)"/o
  QueryMatch_re = /query(\d+)/o
  ParamMatch_re = /(\w+)=(.*)/o
  class << self
   # returns {'<type>' => [start_byte, num_bytes]}
    # type is one of: parameters, masses, unimod, enzyme, header, summary,
    # decoy_summary, peptides, proteins, index  (maybe more of
    # these, but it will get them too)
    # NOTE: the key 'query' returns an array indexed on query number
    #   eg: index['parameters']  # -> [70, 211]
    #       index['query']       # -> [[3001,70], [3071,80], [3152,75]...]
    #       index['query'][75]   # -> [8542,93] # start & length for query 75
    # REWINDS the io
    def index(io)  # :nodoc:
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
      # add a placeholder for the index
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

    # convenience method to index a filename
    def index_file(filename); File.open(filename) {|io| index(io) } end

    # transforms dat parameters into a hash, should work on most sections
    # except the unimod xml
    def str_to_hash(string, hash={})   # :nodoc:
      string.each("\n") do |line|
        md = ParamMatch_re.match(line)
        hash[md[1]] = md[2]
      end
      hash
    end

    def create_index_methods(obj, names)
      names.each do |key|
        unless obj.respond_to? key
          obj.instance_eval( "def #{key}(); read_section(index['#{key}']); end" )
        end
      end
    end

    def open(filename, &block)
      File.open(filename) do |io|
        obj = self.new(io)
        create_index_methods(obj, obj.index.keys )
        block.call(obj)
      end
    end
  end

  attr_reader :index
  attr_reader :io

  # use Dat.open(filename, &block) rather than this.
  def initialize(io) # :nodoc:
    @io = io
    @index = self.class.index(io)
    @query_index_ar = @index['query']
  end
  
  def each_query(&block)
    @query_index_ar.each do |ar|
      if ar
        block.call( Ms::Mascot::Dat::Query.new( read_section(ar) ) )
      end
    end
  end

  def query(num)
    Ms::Mascot::Dat::Query.new( @query_ar[num] )
  end

  # Returns a string
  # takes an ar: [pos, length]
  def read_section(ar) # :nodoc
    @io.pos = ar.first
    @io.read(ar.last)
  end

end
