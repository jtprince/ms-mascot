require 'ms/mascot/mgf/entry'

module Ms
  module Mascot
    module Format
      
      # :startdoc::manifest formats an input spectrum as mgf
      # Formats the data produced by an Ms::Mascot::Fragment task as MGF. The
      # configurations specify various details of the dump, including the
      # precision and default headers.
      #
      #   % rap fragment TVQQEL --:s mgf
      #
      #
      class Mgf < Tap::Task
        
        config :default_headers, {}, &c.hash        # a hash of default headers
        config :min_length, 3, &c.integer_or_nil    # the minimum peptide length
        config :mz_precision, 6, &c.integer         # the precision of mzs
        config :intensity_precision, 0, &c.integer  # the precision of intensities
        config :pepmass_precision, 6, &c.integer    # the precision of peptide mass
        
        HEADER_MAP = {:parent_ion_mass => 'PEPMASS'}
        
        def process(data, headers={})
          entry(data, headers).dump("", config)
        end
        
        def entry(data, headers={})
          mgf_headers = {}
          default_headers.merge(headers).each_pair do |key, value|
            key = HEADER_MAP[key] || key.to_s.upcase
            mgf_headers[key] = value
          end
          
          Ms::Mascot::Mgf::Entry.new(mgf_headers, data)
        end
      end
    end
  end
end