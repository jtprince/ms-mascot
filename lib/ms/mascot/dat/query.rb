require 'ms/mascot/dat/section'

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
  
    class << self
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
  
    # Returns the query index for self (ie 60 when section_name is 'query60')
    attr_reader :index
  
    def initialize(data={}, section_name=self.class.section_name, dat=nil)
      super(data, section_name, dat)
      @index = section_name.strip[5..-1].to_i
      @ions=[]
    end
  
    # Returns the nth ion string in self.
    def ion_str(n=1)
      data["Ions#{n}"]
    end
  
    # Returns a simple array of the parsed nth ion string.
    def ions(n=1)
      @ions[n] ||= Query.parse_ions(ion_str(n))
    end
  
    # Scans the nth ion string, yielding each number and a flag signaling whether
    # or not the number marks the end of a datapoint (ie the number is the
    # intensity).  See Query.scan_ions.
    def scan_ions(n=1)
      Query.scan_ions(ion_str(n)) do |num, end_point|
        yield(num, end_point)
      end
    end
  end
end
