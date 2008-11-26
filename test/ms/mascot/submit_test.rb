require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'ms/mascot/submit'
require 'tap/test/http_test'

class SubmitTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  include Tap::Test::HttpTest
  
  def target
    "http://localhost:2000/echo"
  end
  
  def test_submit
    web_test do
      t = Ms::Mascot::Submit.new(
        :url => target, 
        :request_method => :post,
        :headers => {'Content-Type' => 'multipart/form-data; boundary=1234567890'},
        :params => {:key, 'value'})
        
      res = t.process('path/to/file.txt')
      
      expected = strip_align %Q{
        POST /echo HTTP/1.1
        Accept: */*
        Content-Type: multipart/form-data; boundary=1234567890
        Content-Length: 215
        Host: localhost:2000
        
        --1234567890
        Content-Disposition: form-data; name="key"

        value
        --1234567890
        Content-Disposition: form-data; name="FILE"; filename="path/to/file.txt"
        Content-Type: application/octet-stream

        value
        --1234567890--
        }
      assert_request_equal(expected, res.first.body)
    end
  end
end