# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rusty_json/version'

Gem::Specification.new do |spec|
  spec.name          = "rusty_json"
  spec.version       = RustyJson::VERSION
  spec.authors       = ["Chris MacNaughton"]
  spec.email         = ["chmacnaughton@gmail.com"]

  spec.summary       = "RustyJson is a parser for JSON that takes in a JSON string and outputs Rust structs"
  spec.homepage      = "https://github.com/ChrisMacNaughton/rusty_json"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["rusty_json"] # spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_dependency "json"
end
