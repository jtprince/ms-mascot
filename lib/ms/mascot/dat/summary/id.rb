require 'ms/mascot/dat/summary'

module Ms
  module Mascot
    module Dat
      class Summary
        class Id < Ms::Mascot::Dat::Summary

          PEPTIDE_ATTS = %w(ui0 calc_mr delta start end num_match seq rank ui8 score ui11 ui12 ui13 ui14 ui15 res_before res_after).map {|v| v.to_sym }
          CASTING = {:calc_mr => 'to_f', :delta => 'to_f', :start => 'to_i', :end => 'to_i', :num_match => 'to_i', :rank => 'to_i', :score => 'to_f'}
          
          Peptide = Struct.new(*PEPTIDE_ATTS)

          class Peptide

            class << self 
              def from_strs(hit_string, hit_terms_string)
                vals = hit_string.split(',')
                vals.push( *(hit_terms_string.split(',')) )
                self.new(*vals)
              end

              def from_hash(hash)
                obj = self.new
                hash.each do |k,v|
                  obj[k.to_sym] = v
                end
              end
            end
            PEPTIDE_ATTS.each do |pep_att|
              if CASTING.key? pep_att.to_sym
                class_eval "def #{pep_att}() ; self[:#{pep_att}].#{CASTING[pep_att.to_sym]} end"
              end
            end

          end
        end
      end
    end
  end
end
