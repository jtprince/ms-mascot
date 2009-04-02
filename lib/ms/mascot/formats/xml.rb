require 'nokogiri'

module Ms
  module Mascot
    module Formats
      class Xml
        module Utils
          def hashify(nodes, cast=true)
            nodes.inject({}) do |hash, node|
              value = node.content
              hash[node.name] = cast ? objectify(value) : value
              hash
            end
          end

          def objectify(value)
            case value
            when nil
              nil
            when /\A\d+(\.\d+)?\z/ 
              $1 ? value.to_f : value.to_i
            else
              value
            end
          end
        end
        
        attr_reader :doc
        
        def initialize(xml)
          xml = xml.read if xml.respond_to?(:read)
          xml = xml.sub(%q{xmlns="http://www.matrixscience.com/xmlns/schema/mascot_search_results_2"}, "")
          @doc = Nokogiri::XML(xml)
        end
        
        def header
          doc.at("/mascot_search_results/header")
        end
        
        def modifications
          doc.xpath("/mascot_search_results/variable_mods/modification")
        end
        
        def search_parameters
          doc.xpath("/mascot_search_results/search_parameters")
        end
        
        def format_parameters
          doc.xpath("/mascot_search_results/format_parameters")
        end
        
        def hits
          doc.xpath("/mascot_search_results/hits/hit")
        end
        
        def proteins(hit)
          hit.xpath("protein")
        end
        
        def peptides(protein)
          protein.xpath("peptide")
        end
      end
    end
  end
end