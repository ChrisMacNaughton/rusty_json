require "rusty_json/version"
require "rusty_json/parser"
require "rusty_json/rust_struct"

module RustyJson
  def self.parse(json, name = 'JSON')
    parser = Parser.new(name, json)
    parser.parse
  end
end
