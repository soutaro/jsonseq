# JSONSEQ

JSONSEQ implements reader and writer of JSON Text Sequence defined in [RFC 7464](https://tools.ietf.org/html/rfc7464).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jsonseq'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jsonseq

## Usage

### Reading JSON Text Sequence

Use `JSONSEQ::Reader` to read sequence of JSON objects.

```ruby
require "jsonseq"

reader = JSONSEQ::Reader.new(io: io)

result = reader.read
object = reader.read_object
```

`JSONSEQ::Reader#read` tries to read one object from given IO and returns one of:

* `JSONSEQ::Reader::JSONObject`
* `JSONSEQ::Reader::ParsingError`
* `JSONSEQ::Reader::MaybeTruncated`
* `JSONSEQ::Reader::EndOfFile`

`JSONSEQ::Reader#read_object` tries to read one object from given IO, and returns if successfully read one JSON object.
When reached to end of file, returns `nil`.
Note that `read_object` returns `nil` also when it reads `null`.

It also provides `#each` and `#each_object`.

```ruby
reader.each do |result|
  case result
  when JSONSEQ::Reader::JSONObject
    # ...
  end
end
```

### Writing JSON Text Sequence

Use `JSONSEQ::Writer` to write sequence of JSON objects.

```ruby
require "jsonseq"

writer = JSONSEQ::Writer.new(io: io)

writer << [1,2,3]
writer.write nil
```

It tries to `flush` given IO when it writes an object.

### Customizing JSON encoding/decoding

You can pass `encoder:` and `decoder:` option.

```ruby
JSONSEQ::Reader.new(io: io, decoder: -> (object) { JSON.parse(object, allow_nan: true) })
JSONSEQ::Writer.new(io: io, encoder: -> (object) { JSON.pretty_generate(object) })
```

## Incompatibility

### `JSONSEQ::Reader` accepts a sequence without the first *record separator*

The following input looks like invalid because it does not start with `"\x1E"` (*record separator*).

```
[1,2,3]
\x1E{}
```

However, `JSONSEQ::Reader` accepts that input.

### IO character encoding

RFC 7464 defines the format on UTF-8 encoded stream.
However, this library is implemented without considering IO encoding.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/soutaro/jsonseq.

