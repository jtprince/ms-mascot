Gem::Specification.new do |s|
  s.name = "biomass-mascot"
  s.version = "0.0.1"
  #s.author = "Your Name Here"
  #s.email = "your.email@pubfactory.edu"
  #s.homepage = "http://rubyforge.org/projects/biomass-mascot/"
  s.platform = Gem::Platform::RUBY
  s.summary = "biomass-mascot task library"
  s.require_path = "lib"
  s.test_file = "test/tap_test_suite.rb"
  #s.rubyforge_project = "biomass-mascot"
  #s.has_rdoc = true
  s.add_dependency("tap", "~> 0.10.1")
  s.add_dependency("ms-in_silico", "~> 0.1.0")
  
  # list extra rdoc files like README here.
  s.extra_rdoc_files = %W{
  }
  
  # list the files you want to include here. you can
  # check this manifest using 'rake :print_manifest'
  s.files = %W{
  }
end