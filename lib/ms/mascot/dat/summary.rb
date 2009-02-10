require 'ms/mascot/dat/section'

# Summaries differ in their meaning depending on the type of search but the
# content is in the same format.  The best way to add a sensible api and to
# keep the basic archive lookup structure is to define modules that extend
# a summary with, say an MS/MS ion search api.
class Ms::Mascot::Dat::Summary < Ms::Mascot::Dat::Section
end
