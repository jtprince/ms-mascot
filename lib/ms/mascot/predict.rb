require 'ms/in_silico/digest'
require 'ms/mascot/fragment'
require 'ms/mascot/mgf/archive'

module Ms
  module Mascot

    # Ms::Mascot::Predict::manifest 
    class Predict < Tap::FileTask
      define :digest, InSilico::Digest, {:max_misses => 1}
      define :fragment, Mascot::Fragment, {:intensity => 1}
      
      #config :headers, {}
      config :mz_precision, 6
      config :intensity_precision, 0
      config :pepmass_precision, 6
      
      def workflow
        digest.sequence(fragment, :iterate => true) 
        fragment.on_complete do |_result|
          parent_ion_mass, data = _result._current
          data.delete_if {|mz, intensity| mz < 0 }
          data = data.sort_by {|mz, intensity| mz}
          
          peptide = _result._values[-2]
          headers = {
            'TITLE' => "#{peptide} (#{fragment.series.join(', ')})",
            'CHARGE' => fragment.charge,
            'PEPMASS' => parent_ion_mass}
          
          @entries << Mgf::Entry.new(headers, data) unless data.empty?
        end
      end
      
      def default_path(sequence)
        if sequence.length > 10
          sequence = "#{sequence[0,5]}_#{sequence[-5,5]}"
        end
        
        "#{sequence}.mgf"
      end
      
      def process(sequence, path=nil)
        @entries = []
        digest.execute(sequence)
        
        path = default_path(sequence) if path == nil
        prepare(path)
        File.open(path, "w") do |file|
          @entries.each do |entry|
            entry.puts(file, config)
            file.puts 
          end
        end
        
        path
      end
    end 
  end
end