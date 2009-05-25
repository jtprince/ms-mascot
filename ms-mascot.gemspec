Gem::Specification.new do |s|
  s.name = "ms-mascot"
  s.version = "0.3.0"
  s.authors = ["Simon Chiang", "John Prince"]
  s.email = "simon.a.chiang@gmail.com"
  s.homepage = "http://mspire.rubyforge.org/projects/ms-mascot/"
  s.platform = Gem::Platform::RUBY
  s.summary = "An Mspire library supporting Mascot."
  s.require_path = "lib"
  s.rubyforge_project = "mspire"
  s.has_rdoc = true
  s.add_dependency("tap-mechanize", ">= 0.6.0")
  s.add_dependency("external", ">= 0.3.0")
  s.add_dependency("ms-in_silico", ">= 0.3.0")
  s.rdoc_options.concat %W{--main README -S -N --title Ms-Mascot}
  
  # list extra rdoc files like README here.
  s.extra_rdoc_files = %W{
    README
    MIT-LICENSE
    History
  }
  
  # list the files you want to include here. you can
  # check this manifest using 'rake :print_manifest'
  s.files = %W{
    lib/ms/mascot.rb
    lib/ms/mascot/dat.rb
    lib/ms/mascot/dat/archive.rb
    lib/ms/mascot/dat/header.rb
    lib/ms/mascot/dat/index.rb
    lib/ms/mascot/dat/masses.rb
    lib/ms/mascot/dat/parameters.rb
    lib/ms/mascot/dat/peptides.rb
    lib/ms/mascot/dat/proteins.rb
    lib/ms/mascot/dat/query.rb
    lib/ms/mascot/dat/section.rb
    lib/ms/mascot/dat/summary.rb
    lib/ms/mascot/dat/summary/id.rb
    lib/ms/mascot/export.rb
    lib/ms/mascot/format_mgf.rb
    lib/ms/mascot/fragment.rb
    lib/ms/mascot/mgf.rb
    lib/ms/mascot/mgf/archive.rb
    lib/ms/mascot/mgf/entry.rb
    lib/ms/mascot/spectrum.rb
    lib/ms/mascot/submit.rb
    lib/ms/mascot/validation.rb
    tap.yml
  }
end
