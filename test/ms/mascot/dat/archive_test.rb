require File.join(File.dirname(__FILE__), '../../../tap_test_helper.rb') 
require 'ms/mascot/dat/archive'
require 'stringio'

class DatArchiveUtilsTest < Test::Unit::TestCase
  include Ms::Mascot::Dat::Archive::Utils
  
  #
  # parse_metadata test
  #
  
  def test_parse_metadata_parses_metadata_from_io
    str =  "MIME-Version: 1.0 (Generated by Mascot version 1.0)\n"
    str += "Content-Type: multipart/mixed; boundary=gc0p4Jq0M2Yt08jU534c0p\n"
    io = StringIO.new str
    
    assert_equal({
      :mime_version => '1.0',
      :mascot_version => '1.0',
      :content_type => 'multipart/mixed',
      :boundary => 'gc0p4Jq0M2Yt08jU534c0p'
    }, parse_metadata(io))
  end
  
  def test_parse_metadata_does_not_reposition_io
    str =  "MIME-Version: 1.0 (Generated by Mascot version 1.0)\n"
    str += "Content-Type: multipart/mixed; boundary=gc0p4Jq0M2Yt08jU534c0p\n"
    io = StringIO.new str
    io.pos = 10
    
    assert_equal "gc0p4Jq0M2Yt08jU534c0p", parse_metadata(io)[:boundary]
    assert_equal 10, io.pos
  end
  
  #
  # parse_content_type test
  #
  
  def test_parse_content_type
    assert_equal({
      :content_type => 'application/x-Mascot',
      :name => 'unimod'
    }, parse_content_type('Content-Type: application/x-Mascot; name="unimod"'))
  end
end

class DatArchiveTest < Test::Unit::TestCase
  include Ms::Mascot::Dat
  
  acts_as_file_test
  
  
end