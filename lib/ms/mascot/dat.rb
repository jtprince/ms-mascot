
module Ms; end
module Ms::Mascot; end


=begin
class IO
	def reverse_each(&proc)
		seek(0,SEEK_END)
		i = tell
		j = nil
		buf = ""
		loop do
			k = buf.rindex(10,-2)
			if k then
				proc.call buf.slice!(k+1..-1)
			else
				if i==0 then proc.call(buf); return self; end
				j,i = i,[0,i-4096].max
				seek(i,SEEK_SET)
				buf = read(j-i) + buf
			end
		end
	end
end
=end

class Ms::Mascot::Dat
  MascotSection_re = /Content-Type: application\/x-Mascot; name="(\w+)"/o
  QueryMatch_re = /query(\d+)/o
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
    def index(io)
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

    def open(filename)
    end

  end
end
