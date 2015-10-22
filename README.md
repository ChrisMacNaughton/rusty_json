# RustyJson

[![Quality](https://img.shields.io/codeclimate/github/ChrisMacNaughton/rusty_json.svg?style=flat-square)](https://codeclimate.com/github/ChrisMacNaughton/rusty_json)
[![Coverage](https://img.shields.io/codeclimate/coverage/github/ChrisMacNaughton/rusty_json.svg?style=flat-square)](https://codeclimate.com/github/ChrisMacNaughton/rusty_json)
[![Build](https://img.shields.io/travis-ci/ChrisMacNaughton/rusty_json.svg?style=flat-square)](https://travis-ci.org/ChrisMacNaughton/rusty_json)
[![Dependencies](https://img.shields.io/gemnasium/ChrisMacNaughton/rusty_json.svg?style=flat-square)](https://gemnasium.com/ChrisMacNaughton/rusty_json)
[![Docs](https://inch-ci.org/github/ChrisMacNaughton/rusty_json.svg?branch=master)](http://inch-ci.org/github/ChrisMacNaughton/rusty_json/branch/master)
[![Issues](https://img.shields.io/github/issues/ChrisMacNaughton/rusty_json.svg?style=flat-square)](https://github.com/ChrisMacNaughton/rusty_json/issues)
[![Downloads](https://img.shields.io/gem/dtv/rusty_json.svg?style=flat-square)](https://rubygems.org/gems/rusty_json)
[![Tags](https://img.shields.io/github/tag/ChrisMacNaughton/rusty_json.svg?style=flat-square)](https://github.com/ChrisMacNaughton/rusty_json/tags)
[![Releases](https://img.shields.io/github/release/ChrisMacNaughton/rusty_json.svg?style=flat-square)](https://github.com/ChrisMacNaughton/rusty_json/releases)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/gem/v/rusty_json.svg?style=flat-square)](https://rubygems.org/gems/rusty_json)

RustyJson is a parser for JSON that takes in a JSON string and outputs [Rust](https://www.rust-lang.org/) structs to use with [rustc_serialize](http://doc.rust-lang.org/rustc-serialize/rustc_serialize/index.html) to parse JSON.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rusty_json'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rusty_json

## Usage

```ruby
json = '{"test":64}'
parsed = RustyJson.parse(json)
```

```rust
struct JSON {
  test: i64,
}
```
parsed will equal the JSON struct defined above

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chrismacnaughton/rusty_json.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

