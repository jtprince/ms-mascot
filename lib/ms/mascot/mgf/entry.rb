module Ms
  module Mascot
    module Mgf

      # Represents a mascot generic file (mgf) formatted entry. 
      #
      #   BEGIN IONS
      #   TITLE=7100401blank.190.190.2.dta
      #   CHARGE=2+
      #   PEPMASS=321.571138
      #   100.266 2.0
      #   111.323 2.5
      #   ...
      #   496.110 3.3
      #   601.206 1.3
      #   END IONS
      #
      class Entry
        class << self

          # Parses the entry string into an Mgf::Entry.  The entry must be
          # complete and properly formatted, ie it must begin with a 
          # 'BEGIN IONS' line and end with an 'END IONS' line.
          def parse(str)
            entry = Entry.new

            lines = str.strip.split(/\s*\r?\n\s*/)

            unless lines.shift == "BEGIN IONS"
              raise ArgumentError, "input should begin with 'BEGIN IONS'"
            end

            unless lines.pop == "END IONS"
              raise ArgumentError, "input should end with 'END IONS'"
            end

            lines.each do |line|
              if line =~ /^(.*?)=(.*)$/
                entry[$1] = $2
              else
                entry.data << line.split(/\s+/, 2).collect {|i| i.to_f }
              end
            end

            entry
          end
        end

        # A hash of mgf headers, not including CHARGE and PEPMASS
        attr_reader :headers
        
        # The charge of the entry
        attr_accessor :charge
        
        # The peptide mass of the entry
        attr_accessor :pepmass

        # returns the title of the entry (or nil if none)
        def title
          @headers['TITLE']
        end

        # sets the title
        def title=(string)
          @headers['TITLE'] = string
        end

        # The data (mz/intensity) for the entry
        attr_accessor :data
        
        # Initialized a new Entry using the headers and data.  Set charge
        # and pepmass using the CHARGE and PEPMASS headers.
        def initialize(headers={}, data=[])
          @headers = {}
          @pepmass = nil
          @charge = nil
          @data = data

          headers.each_pair do |key, value|
            self[key] = value
          end
        end

        # Retrieve a header using an mgf header string.  CHARGE and PEPMASS 
        # headers can be retrieved using [], and will reflect the current
        # values of charge and pepmass.  Keys are stringified and upcased.
        def [](key)
          key = key.to_s.upcase
          case key
          when "PEPMASS" then pepmass.to_s
          when "CHARGE" then charge_to_s
          else headers[key]
          end
        end

        # Set a header using an mgf header string.  CHARGE and PEPMASS headers
        # may be set using using []=, and will modify the current values of
        # charge and pepmass.  Keys are stringified and upcased.
        def []=(key, value)
          key = key.to_s.upcase
          case key
          when "PEPMASS" 
            self.pepmass = value.to_f
          when "CHARGE" 
            value = case value
            when Fixnum then value
            when /^(\d+)([+-])$/ then $1.to_i * ($2 == "+" ? 1 : -1) 
            else raise "charge should be an number, or a string formatted like '1+' or '1-'"
            end
            
            self.charge = value
          else
            headers[key] = value
          end
        end

        # Formats and puts self to the target.  Use the options to modify the
        # output:
        #
        # headers:: an array of headers to include (by default all headers 
        #           will be included; pepmass and charge will always be 
        #           included)
        # pepmass_precision::  integer value specifying precision of pepmass
        # mz_precision::  integer value specifying precision of mz values
        # intensity_precision:: integer value specifying precision of intensity
        #                       values
        def dump(target="", options={})
          options = {
            :mz_precision => nil,
            :intensity_precision => nil,
            :pepmass_precision => nil,
            :headers => nil
          }.merge(options)

          target << "BEGIN IONS\n"
          (options[:headers] || headers.keys).each do |key|
            target << "#{key.upcase}=#{headers[key]}\n"
          end
            
          target << "CHARGE=#{charge_to_s}\n"
          target << "PEPMASS=#{format options[:pepmass_precision]}\n" % pepmass

          data_format = "#{format options[:mz_precision]} #{format options[:intensity_precision]}\n"
          data.each do |data_point|
            target << (data_format % data_point)
          end
          
          target << "END IONS\n"
          target
        end

        # Returns self formatted as a string
        def to_s
          dump
        end

        private
        
        # formats the charge as a string
        def charge_to_s # :nodoc:
          charge == nil ? "" : "#{charge.abs}#{charge > 0 ? '+' : '-'}"
        end

        # returns a format string for the specified precision
        def format(precision) # :nodoc:
          precision == nil ? "%s" : "%.#{precision}f"
        end
        
      end
    end
  end
end
