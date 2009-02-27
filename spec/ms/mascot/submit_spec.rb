require File.join(File.dirname(__FILE__), '../../tap_spec_helper.rb') 
require 'ms/mascot/submit'
require 'tap/test/http_test'

class SubmitSpec < MiniTest::Spec
  acts_as_tap_test
  
  include Ms::Mascot
  include Tap::Test::HttpTest

  #
  # describe SUCCESS_REGEXP
  #
  
  it "matches a successful search response" do 
    assert File.read(ctr['success.html']) =~ Submit::SUCCESS_REGEXP
    $1.must_equal "../data/20081202/F011846.dat"
  end
  
  #
  # describe FAILURE_REGEXP
  #
  
  it "matches a failure response" do 
    assert File.read(ctr['error_invalid_file.html']) =~ Submit::FAILURE_REGEXP
    ("\n" + $1).must_equal %Q{
The following error has occured getting your search details:<BR>
Browser specifies 0 bytes of data to be uploaded. Please retry [M00270]<BR>
Have you tried the <A HREF="browser.pl">browser compatibility</A> test page?<BR>}

    assert File.read(ctr['error_invalid_units.html']) =~ Submit::FAILURE_REGEXP
    ("\n" + $1).must_equal %Q{
<BR>Sorry, your search could not be performed due to the following mistake entering data.<BR>
Invalid units (Pork) specified for the "ITOLU" parameter [M00021]<BR>
Please press the back button on your browser, correct the fault and retry the search.<BR>}
  end
  
  #
  # describe process
  #
  
  it "returns .dat filepath on success" do
    server = MockServer.new do |env| 
      [File.read(ctr['success.html'])]
    end
    
    web_test(server) do
      t = Submit.new(:uri => "localhost:2000")
      mgf_file = method_root.prepare(:tmp, 'mgf_file') {}
      t.process(mgf_file).must_equal "../data/20081202/F011846.dat"
    end
  end
  
  it "returns nil on failure" do
    server = MockServer.new do |env| 
      [File.read(ctr['error_invalid_file.html'])]
    end
    
    web_test(server) do
      t = Submit.new(:uri => "localhost:2000")
      mgf_file = method_root.prepare(:tmp, 'mgf_file') {}
      t.process(mgf_file).must_equal nil
    end
  end
end
