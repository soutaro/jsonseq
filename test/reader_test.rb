require "test_helper"

class ReaderTest < Minitest::Test
  def assert_json_object(x, value)
    assert_instance_of JSONSEQ::Reader::JSONObject, x
    assert_equal value, x.object
  end

  def test_read
    io = StringIO.new(<<EOS)
#{JSONSEQ::RS}[1,2,3]
EOS
    reader = JSONSEQ::Reader.new(io: io)

    assert_json_object reader.read, [1,2,3]
  end

  def test_eof
    io = StringIO.new(<<EOS)
EOS
    reader = JSONSEQ::Reader.new(io: io)

    assert_instance_of JSONSEQ::Reader::EndOfFile, reader.read
  end

  def test_broken_json
    io = StringIO.new(<<EOS)
#{JSONSEQ::RS}[1,2,3
EOS
    reader = JSONSEQ::Reader.new(io: io)

    assert_instance_of JSONSEQ::Reader::ParsingError, reader.read
  end

  def test_truncated_literal
    io = StringIO.new(<<EOS)
#{JSONSEQ::RS}123#{JSONSEQ::RS}true
EOS
    reader = JSONSEQ::Reader.new(io: io)

    assert_instance_of JSONSEQ::Reader::MaybeTruncated, reader.read
  end

  def test_literal
    io = StringIO.new(<<EOS)
#{JSONSEQ::RS}123
#{JSONSEQ::RS}true
EOS

    reader = JSONSEQ::Reader.new(io: io)
    assert_json_object reader.read, 123
  end

  def test_nil
    io = StringIO.new(<<EOS)
#{JSONSEQ::RS}null
EOS
    reader = JSONSEQ::Reader.new(io: io)
    result = reader.read

    assert_instance_of JSONSEQ::Reader::JSONObject, result
    assert_nil result.object
  end

  def test_each
    io = StringIO.new(<<EOS)
#{JSONSEQ::RS}123
#{JSONSEQ::RS}true
EOS

    reader = JSONSEQ::Reader.new(io: io)
    results = reader.each.to_a

    assert_equal 3, results.size
    assert_json_object results[0], 123
    assert_json_object results[1], true
    assert_instance_of JSONSEQ::Reader::EndOfFile, results[2]
  end

  def test_read_object
    io = StringIO.new(<<EOS)
#{JSONSEQ::RS}123
#{JSONSEQ::RS}[
#{JSONSEQ::RS}123#{JSONSEQ::RS}null
#{JSONSEQ::RS}true
EOS

    reader = JSONSEQ::Reader.new(io: io)

    assert_equal 123, reader.read_object
    # Skips broken JSON text
    # Skips truncated text
    assert_nil reader.read_object
    assert_equal true, reader.read_object
    # Returns nil at end of file
    assert_nil reader.read_object
  end

  def test_each_object
    io = StringIO.new(<<EOS)
#{JSONSEQ::RS}123
#{JSONSEQ::RS}[
#{JSONSEQ::RS}123#{JSONSEQ::RS}null
#{JSONSEQ::RS}true
EOS
    reader = JSONSEQ::Reader.new(io: io)

    assert_equal [123, nil, true], reader.each_object.to_a
  end
end
