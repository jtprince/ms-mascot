module Ms
  module Mascot
    module Validation
      MASCOT_SWITCH = lambda do |input|
        input = case input
        when true, 1, '1', /true/i   then '1'
        when false, 0, '0', /false/i then '0'
        else input
        end
        
        Configurable::Validation::validate(input, ['1', '0'])
      end
      
      Configurable::DEFAULT_ATTRIBUTES[MASCOT_SWITCH] = {:type => :switch}
    end
  end
end