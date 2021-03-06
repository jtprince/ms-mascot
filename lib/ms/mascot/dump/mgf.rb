require 'tap/tasks/dump'
require 'ms/mascot/mgf/entry'

module Ms
  module Mascot
    module Dump
      # :startdoc::task dumps a fragment spectrum as mgf
      #
      # Formats the data produced by an Ms::Mascot::Fragment task as an mgf. The
      # configurations specify various details of the dump, including the
      # precision and default headers.
      #
      #   % tap run -- fragment TVQQEL --: dump/mgf
      #
      # :startdoc::task-
      #
      # Examples:
      # 
      #   # reformat an mgf file (inefficient but works)
      #   % rap load/mgf --file OLD_FILE --:i dump/mgf --mz-precision 2 > NEW_FILE
      #
      class Mgf < Tap::Tasks::Dump
      
        config :default_headers, {}, &c.hash        # A hash of default headers
        config :mz_precision, 6, &c.integer         # The precision of mzs
        config :intensity_precision, 0, &c.integer  # The precision of intensities
        config :pepmass_precision, 6, &c.integer    # The precision of peptide mass
      
        config :prefix, nil, &c.string_or_nil       # An optional prefix
        config :suffix, "\n", &c.string_or_nil      # An optional suffix
      
        # Maps common variations of header keys (typically output
        # by a fragment task) to Mgf::Entry header strings.
        HEADER_MAP = {:parent_ion_mass => 'PEPMASS'}
      
        # Dumps the object to io as YAML.
        def dump(obj, io)
          unless obj.kind_of?(Ms::Mascot::Mgf::Entry)
            data, headers = obj
            mgf_headers = format_headers(headers)
            obj = Ms::Mascot::Mgf::Entry.new(mgf_headers, data)
          end
          
          io << prefix if prefix
          obj.dump(io, config)
          io << suffix if suffix
        end
        
        protected
      
        # helper to format the headers properly for an mgf entry
        def format_headers(headers) # :nodoc:
          headers ||= {}
          mgf_headers = {}
          default_headers.merge(headers).each_pair do |key, value|
            key = HEADER_MAP[key] || key.to_s.upcase
            mgf_headers[key] = value
          end
          mgf_headers
        end
      end
    end
  end
end