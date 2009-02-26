require 'ms/mascot/dat/section'

# Index maps section names to the line at which the multipart break (ex
# '--gc0p4Jq0M2Yt08jU534c0p') occurs.  Achive creates it's own index and
# does not make use of this section.
#
#   Content-Type: application/x-Mascot; name="index"
#   
#   parameters=4
#   masses=78
#   unimod=117
#   ...
#
# Index is a standard Section and simply defines methods for convenient
# access.  See Section for parsing details.
class Ms::Mascot::Dat::Index < Ms::Mascot::Dat::Section
end
