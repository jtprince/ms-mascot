require 'ms/mascot/mgf/entry'

module Ms
  module Mascot
    module Format
      
      # :startdoc::manifest formats an fragment spectrum as mgf
      #
      # Formats the data produced by an Ms::Mascot::Fragment task as mgf. The
      # configurations specify various details of the dump, including the
      # precision and default headers.
      #
      #   % rap fragment TVQQEL --:s mgf
      #
      # (be sure to use the splat option on the join)
      #
      class Mgf < Tap::Task
        
        config :default_headers, {}, &c.hash        # a hash of default headers
        config :min_length, 3, &c.integer_or_nil    # the minimum peptide length
        config :mz_precision, 6, &c.integer         # the precision of mzs
        config :intensity_precision, 0, &c.integer  # the precision of intensities
        config :pepmass_precision, 6, &c.integer    # the precision of peptide mass
        
        config :prefix, nil, &c.string_or_nil       # an optional prefix
        config :suffix, "\n", &c.string_or_nil      # an optional suffix
        
        # Maps header keys (typically output by a fragment task)
        # to Mgf::Entry header strings.
        HEADER_MAP = {:parent_ion_mass => 'PEPMASS'}
        
        def process(data, headers={})
          lines = []
          lines << prefix if prefix
          
          mgf_headers = format_headers(headers)
          Ms::Mascot::Mgf::Entry.new(mgf_headers, data).dump(lines, config)
          
          lines << suffix if suffix
          lines.join("")
        end
        
        protected
        
        # helper to format the headers properly for an mgf entry
        def format_headers(headers) # :nodoc:
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