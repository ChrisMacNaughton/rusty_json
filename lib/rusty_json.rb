require "rusty_json/version"
require "rusty_json/parser"
require "rusty_json/rust_struct"

# RustyJson is a gem to support [Rust](https://www.rust-lang.org) development
# when using JSON. For a deeply nested JSON object, one may create many
# structs to define the syntax of the expected JSON. RustyJson merely
# Aims to reduce that :)

module RustyJson
  # Example Usage:
  #
  # json = File.read('json_file.json')
  # rust = RustyJson.parse(json)
  # File.write('output_structs.rs', rust)
  #
  # In the above example, RustyJson will parse the JSON in the file:
  # json_file.json and then you print the rust structs out to a Rust
  # File.

  def self.parse(json, name = 'JSON')
    parser = Parser.new(name, json)
    parser.parse
  end
end
