Gem::Specification.new do |s|
  s.name = "ms-mascot"
  s.version = "0.0.1"
  s.author = "Simon Chiang"
  s.email = "simon.a.chiang@gmail.com"
  s.homepage = "http://mspire.rubyforge.org/projects/ms-mascot/"
  s.platform = Gem::Platform::RUBY
  s.summary = "An Mspire library supporting Mascot."
  s.require_path = "lib"
  s.test_file = "test/tap_test_suite.rb"
  s.rubyforge_project = "mspire"
  s.has_rdoc = true
  s.add_dependency("tap", ">= 0.11")
  s.add_dependency("tap-http", ">= 0.2.0")
  s.add_dependency("external", ">= 0.3.0")
  s.add_dependency("mspire", ">= 0.5.0")
  s.add_dependency("ms-in_silico", ">= 0.0.1")
  s.add_development_dependency("ms-testdata", ">= 0.0.1")
  
  # list extra rdoc files like README here.
  s.extra_rdoc_files = %W{
    README
    MIT-LICENSE
  }
  
  # list the files you want to include here. you can
  # check this manifest using 'rake :print_manifest'
  s.files = %W{
    cmd/generate_mgf.rb
    cmd/generate_prospector_mgf.rb
    cmd/reformat_mgf.rb
    lib/ms/mascot.rb
    lib/ms/mascot/fragment.rb
    lib/ms/mascot/mgf.rb
    lib/ms/mascot/mgf/archive.rb
    lib/ms/mascot/mgf/entry.rb
    lib/ms/mascot/predict.rb
    lib/ms/mascot/spectrum.rb
  }
end