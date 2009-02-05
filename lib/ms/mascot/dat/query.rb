require 'ms/mascot/dat/section'

class Ms::Mascot::Dat::Query < Ms::Mascot::Dat::Section
  
  attr_reader :index
  
  def initialize(data={}, section_name=self.class.section_name)
    super(data, section_name)
    @index = section_name[5..-1].to_i
  end
end
