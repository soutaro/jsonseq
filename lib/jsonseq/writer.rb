module JSONSEQ
  class Writer
    DEFAULT_ENCODER = -> (object) { JSON.dump(object) }

    attr_reader :io
    attr_reader :encoder

    def initialize(io:, encoder: DEFAULT_ENCODER)
      @io = io
      @encoder = encoder
    end

    def <<(object)
      io.write RS
      io.write encoder[object]
      io.write LF
      io.flush
    end

    def write(object)
      self << object
    end
  end
end
