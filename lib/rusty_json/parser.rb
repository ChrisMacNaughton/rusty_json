require 'json'
require 'set'

module RustyJson
  # Parser is the base class that actually parses JSON into Rust structs
  #
  # Example:
  # ```ruby
  # name = 'Test'
  # json = '{"hello": "world"}'
  # parser = Parser.new(name, json)
  # parser.parse
  # ```
  class Parser
    # @param name [String] the name of the returned root JSON struct
    # @param json [String] the JSON string to parse into a Rust struct
    def initialize(name, json)
      @name = name
      @json = json
    end

    # parse takes the given JSON string and turns it into a string of
    # Rust structs, suitable for use with rustc_serialize.
    def parse
      (type, subtype) = parse_object([@name], JSON.parse(@json))
      (subtype || type).to_s
    end

    private

    def parse_name(name)
      name.split('_').map(&:capitalize).join
    end

    def parse_object(key_path, object)
      if object.is_a? Array
        parse_array(key_path, object)
      elsif object.is_a? Hash
        parse_hash(key_path, object)
      else
        parse_value(key_path, object)
      end
    end

    def parse_hash(key_path, hash)
      name = key_path.map { |key| parse_name(key) }.join('_')
      struct = RustStruct.new(name)
      hash.each do |key, value|
        struct.add_value(key, *parse_object(key_path + [key], value))
      end
      [struct, nil]
    end

    def parse_array(key_path, array)
      if Set.new(array.map(&:class)).count > 1
        fail('Cannot handle multi-typed arrays')
      end
      object = (array.first.is_a? Hash) ? densify_array(array) : array.first
      subtype = array.empty? ? nil : parse_object(key_path, object).first
      [Array, subtype]
    end

    def parse_value(_key_path, value)
      [value.class, nil]
    end

    def densify_array(array)
      # Try to get rid of as much ambiguity, as possible:
      object = array.first
      array.each do |hash|
        hash.each do |key, value|
          object[key] ||= value
        end
      end
      object
    end
  end
end
