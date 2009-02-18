require 'ms/in_silico/digest'
require 'ms/mascot/fragment'
require 'ms/mascot/mgf/archive'

module Ms
  module Mascot

    # Ms::Mascot::Predict::manifest predicts the spectra for a protein sequence
    #
    # Fragments a protein sequence and calculates the fragment spectra for
    # each peptide.  The peptide spectra are formatted as mgf and dumped to
    # the target. 
    #
    #   % rap predict MAEELVLERCDLELETNGRDHHTADLCREKLVVRRGQPFWLTLHFEGRNYEASVDSLTFS
    #     I[16:30:19]             digest MAEELVLERCD... to 15 peptides
    #     I[16:30:19]           fragment MAEELVLER
    #     I[16:30:19]           fragment MAEELVLERCDLELETNGR
    #     I[16:30:19]           fragment CDLELETNGR
    #     I[16:30:19]           fragment CDLELETNGRDHHTADLCR
    #     I[16:30:19]           fragment DHHTADLCR
    #     I[16:30:19]           fragment DHHTADLCREK
    #     I[16:30:19]           fragment EKLVVR
    #     I[16:30:19]           fragment LVVR
    #     I[16:30:19]           fragment LVVRR
    #     I[16:30:19]           fragment RGQPFWLTLHFEGR
    #     I[16:30:19]           fragment GQPFWLTLHFEGR
    #     I[16:30:19]           fragment GQPFWLTLHFEGRNYEASVDSLTFS
    #     I[16:30:19]           fragment NYEASVDSLTFS
    #
    class Predict < Tap::FileTask
      define :digest, InSilico::Digest, {:max_misses => 1}
      define :fragment, Mascot::Fragment, {:intensity => 1, :unmask => true, :sort => true}
      
      config :headers, nil, &c.hash_or_nil        # a hash of headers to include
      config :min_length, 3, &c.integer_or_nil    # the minimum peptide length
      config :mz_precision, 6, &c.integer         # the precision of mzs
      config :intensity_precision, 0, &c.integer  # the precision of intensities
      config :pepmass_precision, 6, &c.integer    # the precision of peptide mass
      
      # Sequences digest and fragment.  When fragment completes, it will add
      # a new mgf entry to the internal entries collection.
      def workflow
        digest.on_complete do |_results|
          _results.splat.each do |_result|
            next if min_length && _result.value.length < min_length
            fragment._execute(_result)
          end
        end
     
        fragment.on_complete do |_result|
          parent_ion_mass, data = _result.value
          next if data.empty?
          
          peptide = _result.sources[0].value
          headers = {
            'TITLE' => "#{peptide} (#{fragment.series.join(', ')})",
            'CHARGE' => fragment.charge,
            'PEPMASS' => parent_ion_mass}
          
          @entries << Mgf::Entry.new(headers, data) 
        end
      end
      
      def process(sequence)
        sequence = sequence.gsub(/\s/, "")
        
        @entries = []
        digest.execute(sequence)
        
        @entries.collect do |entry|
          entry.dump("", config)
        end.join("\n")
      end
    end 
  end
end