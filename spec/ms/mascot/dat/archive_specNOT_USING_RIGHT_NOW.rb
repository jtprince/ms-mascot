require File.join(File.dirname(__FILE__), '../../../tap_spec_helper.rb') 
require 'ms/mascot/dat/archive'
require 'stringio'

class DatArchiveUtilsSpec < MiniTest::Spec
  include Ms::Mascot::Dat::Archive::Utils
  
  #
  # describe Utils.parse_metadata
  #
  
  it 'parses metadata from io' do
    str =  "MIME-Version: 1.0 (Generated by Mascot version 1.0)\n"
    str += "Content-Type: multipart/mixed; boundary=gc0p4Jq0M2Yt08jU534c0p\n"
    io = StringIO.new str

    parse_metadata(io).must_equal( {
      :mime_version => '1.0',
      :mascot_version => '1.0',
      :content_type => 'multipart/mixed',
      :boundary => 'gc0p4Jq0M2Yt08jU534c0p'
    } )
  end
  
  it 'does not reposition io' do
    str =  "MIME-Version: 1.0 (Generated by Mascot version 1.0)\n"
    str += "Content-Type: multipart/mixed; boundary=gc0p4Jq0M2Yt08jU534c0p\n"
    io = StringIO.new str
    io.pos = 10
    parse_metadata(io)[:boundary].must_equal "gc0p4Jq0M2Yt08jU534c0p"
    io.pos.must_equal 10
  end
  
  #
  # describe Utils.parse_content_type
  #
  
  it 'must parse the content type header and section name' do
    parse_content_type('Content-Type: application/x-Mascot; name="unimod"').must_equal( {
      :content_type => 'application/x-Mascot',
      :section_name => 'unimod'
    } )
  end
  
  it 'must raise an error for unparseable headers' do
    e = lambda { parse_content_type('invalid') }.must_raise(RuntimeError)
    e.message.must_equal "unparseable content-type declaration: \"invalid\""
  end
end

class DatArchiveTest < MiniTest::Spec
  include Ms::Mascot::Dat
  
  acts_as_file_test
  
  MODEL_DAT = %Q{
MIME-Version: 1.0 (Generated by Mascot version 1.0)
Content-Type: multipart/mixed; boundary=gc0p4Jq0M2Yt08jU534c0p

--gc0p4Jq0M2Yt08jU534c0p
Content-Type: application/x-Mascot; name="one"

section one
content
--gc0p4Jq0M2Yt08jU534c0p
Content-Type: application/x-Mascot; name="two"

section two
content
--gc0p4Jq0M2Yt08jU534c0p--
}.strip

  attr_accessor :io
  
  before do
    super
    @io = StringIO.new(MODEL_DAT)
  end
  
  #
  # describe Archive#new
  #
  
  it 'must parse metadata' do
    dat = Archive.new(io)
    dat.metadata.must_equal( {
      :mime_version => '1.0',
      :mascot_version => '1.0',
      :content_type => 'multipart/mixed',
      :boundary => 'gc0p4Jq0M2Yt08jU534c0p'
    })
  end
  
  #
  # describe Archive.boundary
  #
  
  it 'formats a multipart/form boundary from metadata[:boundary]' do
    dat = Archive.new(io)
    dat.boundary.must_equal "--gc0p4Jq0M2Yt08jU534c0p"
  end
  
  #
  # describe Archive.reindex
  #
  
  it 'indexes based on boundary' do
    dat = Archive.new(io)
    dat.reindex
    
    dat.length.must_equal 2
    ("\n" + dat[0]).must_equal %Q{

Content-Type: application/x-Mascot; name="one"

section one
content
}

    ("\n" + dat[1]).must_equal %Q{

Content-Type: application/x-Mascot; name="two"

section two
content
}
  end
  
  it 'must return self' do
    dat = Archive.new(io)
    dat.reindex.must_equal dat
  end
  
  #
  # describe Archive.str_to_entry
  #

  PARAMETERS_SECTION = %Q{

Content-Type: application/x-Mascot; name="parameters"

LICENSE=Licensed to: Matrix Science Internal use only - Frill, (4 processors).
MP=
NM=
COM=Peptide Mass Fingerprint Example
IATOL=
}

  it 'parses known content types into hashes' do
    dat = Archive.new(io)
    p = dat.str_to_entry(PARAMETERS_SECTION)
    p.must_be_instance_of Ms::Mascot::Dat::Parameters
    p.data.must_equal({
      'LICENSE' => 'Licensed to: Matrix Science Internal use only - Frill, (4 processors).',
      'MP' => '',
      'NM' => '',
      'COM' => 'Peptide Mass Fingerprint Example',
      'IATOL' => ''
    })
  end
  
  #
  # describe Archive.section_names
  #
  
  it 'must return all section names' do
    dat = Archive.new(io).reindex
    dat.section_names.must_equal ['one', 'two']
  end
  
  it 'only resolves section names if specified' do
    dat = Archive.new(io).reindex
    dat.section_names(false).must_equal []
    dat.section_names(true).must_equal ['one', 'two']
  end
  
  #
  # describe Archive.section_index
  #
  
  it 'gives index of the named section' do
    dat = Archive.new(io).reindex
    dat.section_index("one").must_equal 0
    dat.section_index("two").must_equal 1
  end
  
  it 'returns nil for an unknown section' do
    dat = Archive.new(io).reindex
    dat.section_index("unknown").must_equal nil
  end
  
  #
  # describe Archive.section_name
  #
  
  it 'gives name of section at index' do
    dat = Archive.new(io).reindex
    dat.section_name(1).must_equal "two"
    dat.section_name(0).must_equal "one"
  end
  
  it 'allows negative indicies' do
    dat = Archive.new(io).reindex
    dat.section_name(-1).must_equal "two"
  end
  
  it 'returns nil for an index out of range' do
    dat = Archive.new(io).reindex
    assert_equal 2, dat.length
    assert_equal nil, dat.section_name(10)
  end
end