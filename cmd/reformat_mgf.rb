# = Usage
# tap reformat_mgf {options} MGF_FILES
#
# = Description
# Reformats mgf files to a standard output like:
#
#   BEGIN IONS
#   TITLE=7100401blank.190.190.2.dta
#   CHARGE=2+
#   PEPMASS=321.571138
#   100.266 2.0
#   111.323 2.5
#   ...
#   496.110 3.3
#   601.206 1.3
#   END IONS
#
# = Information
#
# Copyright (c) 2006-2007, Regents of the University of Colorado.
# Developer:: Simon Chiang, Biomolecular Structure Program
# Homepage:: http://hsc-proteomics.uchsc.edu/hansen_lab
# Support:: CU Denver School of Medicine Deans Academic Enrichment Fund
#
require 'tap/script'

app = Tap::App.instance   

#
# handle options
#

opts = [
  ['--target_dir', '-t', GetoptLong::REQUIRED_ARGUMENT, "Specify an output directory."],
  ['--mz_precision', '-m', GetoptLong::REQUIRED_ARGUMENT, "Specify the mz precision."],
  ['--intensity_precision', '-i', GetoptLong::REQUIRED_ARGUMENT, "Specify the intensity precision."],
  ['--pepmass_precision', '-p', GetoptLong::REQUIRED_ARGUMENT, "Specify the peptide mass precision."],
  ['--headers', nil, GetoptLong::REQUIRED_ARGUMENT, "Specify the headers to include, separated by commas."],
  ['--help', '-h', GetoptLong::NO_ARGUMENT, "Print this help."],
  ['--debug', nil, GetoptLong::NO_ARGUMENT, "Specifies debug mode."]]

config = {:target_dir => 'reformatted'}

Tap::Script.handle_options(*opts) do |opt, value| 
  case opt
  when '--help'
    puts Tap::Script.usage(__FILE__, "Usage", "Description", "Information", :keep_headers => false)
    puts
    puts Tap::Script.usage_options(opts)
    exit
    
  when '--debug'
    app.options.debug = true

  when '--headers'
    value = value[1..-2] if value[0] == 34 && value[-1] == 34
    config[:headers] = value.split(/,/).collect {|header| header.strip}
  else
    opt =~ /--(.*)/
    config[$1.to_sym] = value
  
  end
end

#
# add your script code here
#

require 'mascot/formats/mgf'

reformat = Tap::FileTask.new("", config) do |task, input|
  target = task.filepath(task.config[:target_dir], File.basename(input))
  task.prepare(target)

  task.log_basename :reformatting, input
  Mascot::Formats::Mgf::Archive.open(input) do |archive|
    archive.reindex if archive.length == 0
    
    File.open(target, "wb") do |output|
      archive.each do |mgf|
        mgf.puts(output, task.config)
        output.puts
      end
    end
  end
end

args = ARGV.dup
ARGV.clear
app.run(reformat, *args)
