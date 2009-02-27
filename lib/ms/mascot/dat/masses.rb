require 'ms/mascot/dat/section'

# Masses contains the masses of elements, residues, particles (like 'Electron')
# and the delta masses for modifications used in an identification, including
# the mass of various neutral losses.
#
#   Content-Type: application/x-Mascot; name="masses"
#   
#   A=71.037114
#   B=114.534940
#   C=103.009185
#   D=115.026943
#   ...
#
# Masses is a standard Section and simply defines methods for convenient
# access.  See Section for parsing details.
class Ms::Mascot::Dat::Masses < Ms::Mascot::Dat::Section
end