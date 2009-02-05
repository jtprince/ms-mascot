require 'ms/mascot/dat/section'

# Summaries differ in their meaning depending on the type of search but the
# content is in the same format.  The best way to add a sensible api and to
# keep the basic archive lookup structure is to define modules that extend
# a summary with, say an MS/MS ion search api.
class Ms::Mascot::Dat::Summary < Ms::Mascot::Dat::Section
end


# some notes on deciphering the summary (in progress):

# note peptide start and end have to be adjusted for Methionines!
# XX is unknowable ...
# h14_q2=0,936.455246,0.001202,53,61,4.00,GYASPDLSK,16,00000000000,22.56,1,0002001000000000000,0,0,1671.400000
# query=[Miss?, Mr(expt), deltamass, peptide_start, peptide_end, XX, Peptide, (??), Score,\
# Rank, (??), Miss?, Miss?, (??)

#qmass1=360.001144
#qexp1=361.008420,1+
#qmatch1=0
#qplughole1=0.000000

#num_hits=50
#h1=IPI00796844,6.24e+01,0.25,49327.29
#h1_text=Tax_Id=9606 Gene_Symbol=HSP90AA1 Full-length cDNA clone CS0CAP007YF18 of Thymus of Homo sapiens
#h1_q1=-1
#h1_q2=-1
#h1_q3=-1
#h1_q4=1,2440.202271,0.002511,311,331,17.00,HIYYITGETKDQVANSAFVER,68,00000000000000000000000,53.72,1,0001012020000000000,0,0,20611.800000
#h1_q4_terms=K,L

