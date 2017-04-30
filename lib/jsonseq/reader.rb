module JSONSEQ
  class Reader
    DEFAULT_DECODER = -> (string) { JSON.parse(string) }

    class JSONObject
      attr_reader :object

      def initialize(object:)
        @object = object
      end
    end

    class EndOfFile
    end

    class ParsingError
      attr_reader :source
      attr_reader :exception

      def initialize(source:, exception:)
        @source = source
        @exception = exception
      end
    end

    class MaybeTruncated
      attr_reader :source
      attr_reader :object

      def initialize(source:, object:)
        @source = source
        @object = object
      end
    end

    attr_reader :io
    attr_reader :decoder

    def initialize(io:, decoder: DEFAULT_DECODER)
      @io = io
      @decoder = decoder
    end

    def read
      begin
        source = io.readline(RS).chomp(RS)
      end while source == ""

      object = decode_string(source)

      case object
      when Numeric, TrueClass, FalseClass, nil
        if truncated?(source)
          MaybeTruncated.new(source: source, object: object)
        else
          JSONObject.new(object: object)
        end
      when ParsingError
        object
      else
        JSONObject.new(object: object)
      end
    rescue EOFError
      EndOfFile.new
    end

    def each
      if block_given?
        while true
          object = read
          yield object
          return if object.is_a?(EndOfFile)
        end
      else
        enum_for :each
      end
    end

    def read_object
      value = read
      case value
      when MaybeTruncated, ParsingError
        read_object
      when EndOfFile
        nil
      when JSONObject
        value.object
      else
        raise "Unexpected value: #{value}"
      end
    end

    def each_object
      if block_given?
        each do |value|
          if value.is_a?(JSONObject)
            yield value.object
          end
        end
      else
        enum_for :each_object
      end
    end

    private

    def decode_string(string)
      decoder[string]
    rescue => exn
      ParsingError.new(source: string, exception: exn)
    end

    def truncated?(string)
      !string.end_with?(LF, "\x20", "\x09", "\x0d")
    end
  end
end
