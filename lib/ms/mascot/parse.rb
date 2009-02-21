require 'hpricot'

module Ms
  module Mascot
    # Ms::Mascot::Parse::manifest 
    class Parse < Tap::Task
      
      # Matches the peptide sequence
      SEQUENCE = /Fragmentation of <B><FONT COLOR=#FF0000>(.*?)<\/FONT>/
      
      # Matches for the parent ion mass, score, and expect value
      ATTRIBUTES = /Mr\(calc\):<\/B> (\d+\.\d+)\s<B>Ions Score:<\/B> (\d+)  <B>Expect:<\/B> (\d+\.\d+)/i
      
      config :series, ['y', 'b'], &c.list    # a list of the series to include
      config :charge, 1, &c.integer          # the charge for the parent ion
      config :intensity, nil, &c.num_or_nil  # a uniform intensity value
      
      def process(peptide_view_html)
        
        # parse sequence information
        unless peptide_view_html =~ SEQUENCE
          raise "could not identify sequence"
        end
        sequence = $1
        
        # parse parent ion mass
        unless peptide_view_html =~ ATTRIBUTES
          raise "could not identify match attributes"
        end
        parent_ion_mass, score, expect = $1, $2, $3
        
        # parse series data
        data = []
        series_data(peptide_view_html).each do |frament_series|
          next unless series.include?(frament_series.shift)
          data.concat(frament_series)
        end
        
        data = data.compact.uniq
        data.collect! do |peak|
          [peak, intensity]
        end if intensity
        
        headers = {
          :charge => charge,
          :score => score,
          :expect => expect,
          :parent_ion_mass => parent_ion_mass, # * charge
          :title => "#{sequence} (#{series.compact.join(', ')})"
        }
        
        [data, headers]
      end
      
      def series_data(peptide_view_html)
        doc = Hpricot(peptide_view_html)
        tables = doc.search('html/body//table')
        rows = tables[0].search('tr')
        data = []
        
        # parse headers
        headers = []
        rows.shift.search('th').each do |th|
          header = th.inner_html
          
          headers << case header
          when "#", "Seq." then nil
          else header.gsub(/<\/?sup>/i, "")
          end
        end
        data << headers
          
        # collect datapoints
        rows.each do |tr|
          row = []
          tr.search('td').each do |td|
            value = td.inner_html
            
            row << case value
            when /(\d+\.\d+)/ then $1.to_f
            else nil
            end
          end
          data << row
        end
        
        data.transpose
      end
      
    end 
  end
end