require 'ms/format/format_error'

module Ms
  module Mascot
    module Mgf

      # Entry represents a mascot generic file (mgf) formatted entry. 
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

          # Parses the entry string into an Mgf::Entry.  The entry must be complete, ie
          # begin with a 'BEGIN IONS' line and end with an 'END IONS' line.
          def parse(str)
            entry = Entry.new

            lines = str.strip.split(/\s*\r?\n\s*/)

            unless lines.shift == "BEGIN IONS"
              raise Ms::Format::FormatError.new("input should begin with 'BEGIN IONS'", str)
            end

            unless lines.pop == "END IONS"
              raise Ms::Format::FormatError.new("input should end with 'END IONS'", str)
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

        # mgf headers, not including CHARGE and PEPMASS
        attr_reader :headers

        attr_accessor :charge
        attr_accessor :pepmass
        attr_accessor :data

        def initialize(headers={}, data=[])
          @headers = {}
          @pepmass = nil
          @charge = nil
          @data = data

          headers.each_pair do |key, value|
            self[key] = value
          end
        end

        # Retrieve a header using an mgf header string.  CHARGE and PEPMASS as
        # formatted strings can  be retrieved as strings using [], and will reflect the 
        # current values of charge and pepmass.
        def [](key)
          key = key.to_s.upcase
          case key
          when "PEPMASS" then pepmass.to_s
          when "CHARGE" then charge_to_s
          else
            headers[key]
          end
        end

        # Set a header using an mgf header string.  CHARGE and PEPMASS can
        # be set using formatted string values using []=, and will modify the current
        # values of charge and pepmass.  
        def []=(key, value)
          key = key.to_s.upcase
          case key
          when "PEPMASS" 
            self.pepmass = value.to_f
          when "CHARGE" 
            value = case value
            when Fixnum then value
            when /^(\d+)([+-])$/ then $1.to_i * ($2 == "+" ? 1 : -1) 
            else
              raise Ms::Format::FormatError.new("charge should be an number, or a string formatted like '1+' or '1-'", value) 
            end
            
            self.charge = value
          else
            headers[key] = value
          end
        end

        # Formats and puts self to the target.  Use the options to modify the output:
        #
        # headers:: an array of headers to include (by default all headers will be included;
        #                  pepmass and charge will always be included)
        # pepmass_precision::  integer value specifying precision of pepmass
        # mz_precision::  integer value specifying precision of mz values
        # intensity_precision:: integer value specifying precision of intensity values
        def puts(target="", options={})
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
          target << ("PEPMASS=#{format options[:pepmass_precision]}\n" % pepmass)

          data_format = "#{format options[:mz_precision]} #{format options[:intensity_precision]}\n"
          data.each do |data_point|
            target << (data_format % data_point)
          end

          #target << "\n"  # added in some cases?  required?
          target << "END IONS\n"
          target
        end

        # Returns self formatted as a string
        def to_s
          puts
        end

        private

        def charge_to_s
          charge == nil ? "" : "#{charge.abs}#{charge > 0 ? '+' : '-'}"
        end

        def format(precision)
          precision == nil ? "%s" : "%.#{precision}f"
        end
        
      end
    end
  end
end