require 'rubygems'
require 'minitest/spec'
require 'tap'
require 'tap/spec'

def xit(name, &block)
end

begin
  require 'ms/testdata'
rescue(LoadError)
  puts %Q{
Tests probably cannot be run because the submodules have
not been initialized. Use these commands and try again:
 
% git submodule init
% git submodule update
 
}
  raise
end
