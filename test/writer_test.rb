require "test_helper"

class WriterTest < Minitest::Test
  def test_write
    writer = JSONSEQ::Writer.new(io: StringIO.new)

    writer.write [1, 2, 3]
    writer << true

    assert_equal "#{JSONSEQ::RS}[1,2,3]#{JSONSEQ::LF}#{JSONSEQ::RS}true#{JSONSEQ::LF}", writer.io.string
  end
end
