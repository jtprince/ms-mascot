# = Usage
# tap generate_mgf {options} protein_sequences
#
# When specifying the ions to include, alternate charge states can be
# specified using + and -, for example 'y++' or 'b-'.  The available ion
# series are [a,b,c,x,y,z].
#
# = Description
# Digests, fragments, then formats the protein sequences into mgf files.
# Use the options to specify/modify digestion enzymes, as well as the
# type of ions to generate.  
#
# = Information
#
# Copyright (c) 2006-2007, Regents of the University of Colorado.
# Developer:: Simon Chiang, Biomolecular Structure Program
# Homepage:: http://hsc-proteomics.uchsc.edu/hansen_lab
# Support:: CU Denver School of Medicine Deans Academic Enrichment Fund
#

require 'tap/script'
include Constants::Library

app = Tap::App.instance   

#
# handle options
#

opts = Prospector::Digest.configurations.to_opts 
opts += Mascot::Formats::Mgf::Print.configurations.to_opts
opts += [
  ['--charge', '-c', GetoptLong::REQUIRED_ARGUMENT, "Parent ion charge for mgf files. (default +1)"],
  
  ['--ions', '-i', GetoptLong::REQUIRED_ARGUMENT, "Comma-separated string of ion series to include. (default 'yb')"],
  #['--enzyme_file', nil, GetoptLong::REQUIRED_ARGUMENT, "Specifes a Prospector-style enzyme config file."],
  ['--residue_precision', nil, GetoptLong::REQUIRED_ARGUMENT, "The precision of residues, ex 6 for 57.021464"],
  ['--help', '-h', GetoptLong::NO_ARGUMENT, "Print this help."],
  ['--debug', nil, GetoptLong::NO_ARGUMENT, "Specifes debug mode."]]

digest_config = {}
print_config = {}
series = "yb"
charge = 1
residue_precision = 6

Tap::Script.handle_options(*opts) do |opt, value| 
  case opt
  when '--help'
    puts Tap::Script.usage(__FILE__, "Usage", "Description", "Information", :keep_headers => false)
    puts
    puts Tap::Script.usage_options(opts)
    exit
    
  when '--debug'
    app.options.debug = true
    
  when '--ions'
    series = value
    
  when '--charge'
    charge = value.to_i
    
  when '--residue_precision'
    residue_precision = value.to_i
    
  else
    key = Prospector::Digest.configurations.opt_map(opt)
    digest_config[key] = YAML.load(value) if key
    
    key = Mascot::Formats::Mgf::Print.configurations.opt_map(opt)
    print_config[key] = YAML.load(value) if key
  end
end

if ARGV.empty?
  puts "no sequences specified"
  exit
end

#
# add your script code here
#
series = series.scan(/\w\-*\+*/)

#loader = Prospector::LoadDigesters.new
#loader.enq(enzyme_file)

#
digest = Prospector::Digest.new(nil, digest_config)

#
n = Molecule[digest.nterm]
c = Molecule[digest.cterm]

fragment = Tap::Task.new do |task, polypeptides|
  polypeptides.collect do |polypeptide, start_index, end_index|
    task.log :fragment, polypeptide.sequence[0..10] + (polypeptide.sequence.length > 10 ? "..." : "")
    
    f = Prospector::FragmentSpectrum.new(polypeptide.sequence, n, c)
  
    headers = {
      :title => polypeptide.sequence,
      :charge => charge,
      :pepmass => (n.mass + polypeptide.mass + c.mass + charge * (Molecule['H'].mass - Particle['Electron'].mass))/charge
    }
  
    data = series.collect {|s| f.series(s)}.flatten.delete_if {|mass| mass < 0 }.sort
    data = [data, Array.new(data.length, 1)].transpose
  
    Mascot::Formats::Mgf::Entry.new(headers, data)
  end
end

#
print = Mascot::Formats::Mgf::Print.new('generate_mgf', print_config)

# workflow
digest.enq(*ARGV)
ARGV.clear 

app.sequence(digest, fragment, print)
app.run
