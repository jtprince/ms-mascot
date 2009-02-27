require 'ms/mascot/dat/section'

# Parameters represents search parameters in a Dat file.  This section appears
# to be a direct dump of the multipart data created by a Mascot search form.
#
#   Content-Type: application/x-Mascot; name="parameters"
#
#   LICENSE=Licensed to: Matrix Science Internal use only - Frill, (4 processors).
#   MP=
#   NM=
#   COM=MS/MS Example
#   IATOL=
#   ...
#
# Parameters is a standard Section and simply defines methods for convenient
# access.  See Section for parsing details.
class Ms::Mascot::Dat::Parameters < Ms::Mascot::Dat::Section
end