require 'ms/mascot/dat/section'
require 'ms/mascot/mgf/entry'
require 'rack'

module Ms::Mascot::Dat
  
  # Query is a generic section for all queryN sections.  Query contains query
  # data that has different meaning depending on the type of search performed.
  # Here is data from an MS/MS search:
  #
  #   Content-Type: application/x-Mascot; name="query60"
  #   
  #   charge=3+
  #   mass_min=50.175000
  #   mass_max=1998.960000
  #   int_min=0.0364
  #   int_max=7366
  #   num_vals=3411
  #   num_used1=-1
  #   Ions1=129.098825:384.8,187.070000:461.5...
  #   ...
  #
  # Query is a standard Section and simply defines methods for convenient
  # access.  See Section for parsing details.
  class Query < Ms::Mascot::Dat::Section
  
    module Utils
      module_function
      
      # Scans an ion string for values, yielding each number as a string and the
      # a flag signaling whether or not the number marks the end of a datapoint
      # (ie the number is the intensity).
      #
      #   str = "\nReformatted Ions\n"
      #   Query.scan_ions('1.23:4.56,7.8:9') do |num, end_point|
      #     str << num
      #     str << (end_point ? "\n" : " ")
      #   end
      #
      #   str
      #   # => %q{
      #   # Reformatted Ions
      #   # 1.23 4.56
      #   # 7.8 9
      #   # }
      #
      def scan_ions(str) # :yields: num, end_point
        scanner = StringScanner.new(str)
        while num = scanner.scan(/[^:,]+/)
          if scanner.skip(/:/)
            yield(num, false)
          else
            scanner.skip(/,/)
            yield(num, true)
          end 
        end
      end
    
      # Parses an ion string into a simple data array.  Parse ions requires
      # data points be separated with a comma and mz/intensity values with a
      # semicolon, but is tolerant to integer and floats.
      #
      #   Query.parse_ions('1.23:4.56,7.8:9')     # => [[1.23, 4.56], [7.8, 9]]
      #
      # All ions are cast to floats; see scan_ions for scanning the string
      # values.
      def parse_ions(str)
        ions = []
        current = []
      
        scan_ions(str) do |num, end_point|
          current << num.to_f
        
          if end_point
            ions << current
            current = []
          end
        end
        ions
      end
    end
    
    include Utils
    
    # Returns the query index for self (ie 60 when section_name is 'query60')
    attr_reader :index
  
    def initialize(data={}, section_name=self.class.section_name, dat=nil)
      super(data, section_name, dat)
      data['title'] = Rack::Utils.unescape(data['title'].to_s)
      @index = section_name.strip[5..-1].to_i
      @ions=[]
    end
  
    # Returns the nth ion string in self.
    def ion_str(n=1)
      data["Ions#{n}"]
    end
  
    # Returns a simple array of the parsed nth ion string.
    def ions(n=1)
      @ions[n] ||= parse_ions(ion_str(n))
    end

    def title
      data['title']
    end

    # allows access to values in data with method calls
    #def method_missing(*args)
    #  if args.size == 1 && (val = data[arg.to_s])
    #    val
    #  else
    #    super(*args)
    #  end
    #end

    # returns a Ms::Mascot::Mgf::Entry object.  
    # pepmass may be a Numeric OR a PeptideHit object (extracting the pepmass
    # by PeptideHit#peptide_mass + PeptideHit#delta_mass
    # options are:
    #
    #     :valid_headers = true (default) | false
    def to_mgf(pepmass, opts={})
      opts = {:valid_headers => true}.merge(opts)
      valid_headers = opts[:valid_headers]
      header = {}
      header['PEPMASS'] = 
        if pepmass.is_a? Numeric
          pepmass
        else
          hit = pepmass
          hit.peptide_mass + hit.delta_mass
        end
      data.each_pair do |key,value|
        up = key.to_s.upcase
        next if key =~ /Ions/ 
        next if valid_headers && !Ms::Mascot::Mgf::VALID_LOCAL_HEADERS.include?(up)
        header[up] = value
      end
      # note that we sort the ions because I think I've seen files without
      # them being sorted
      Ms::Mascot::Mgf::Entry.new(header, self.ions.sort)
    end

  end
end
