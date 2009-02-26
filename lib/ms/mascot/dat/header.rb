require 'ms/mascot/dat/section'

# Header contains information describing the search environment, especially
# features of the search database, but also search statistics, like exec_time.
#
#   Content-Type: application/x-Mascot; name="header"
#   
#   sequences=257964
#   sequences_after_tax=257964
#   residues=93947433
#   ...
#
# Header is a standard Section and simply defines methods for convenient
# access.  See Section for parsing details.
class Ms::Mascot::Dat::Header < Ms::Mascot::Dat::Section
end