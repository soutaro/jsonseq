require "test_helper"

class WriterTest < Minitest::Test
  def test_write
    io = StringIO.new
    writer = JSONSEQ::Writer.new(io: io)

    writer.write [1, 2, 3]
    writer << true

    assert_equal "#{JSONSEQ::RS}[1,2,3]#{JSONSEQ::LF}#{JSONSEQ::RS}true#{JSONSEQ::LF}", io.string
  end
end
