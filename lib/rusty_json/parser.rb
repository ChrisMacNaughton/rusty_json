require 'json'
require 'set'

module RustyJson
  class Parser
    # BASE_TYPES are merely Rust base types that we use before adding our own
    # Structs to them.
    BASE_TYPES = {
      String => 'String',
      Fixnum => 'i64',
      Float => 'f64',
    }

    # @param name [String] the name of the returned root JSON struct
    # @param json [String] the JSON string to parse into a Rust struct
    def initialize(name, json)
      @name = name
      @json = json
      @struct_names = Set.new
      @structs = Set.new
    end

    # parse takes the given JSON string and turns it into a string of
    # Rust structs, suitable for use with rustc_serialize.
    def parse
      @parsed = JSON.parse(@json)
      if @parsed.is_a? Hash
        struct = parse_hash(@name, @parsed)
      end
      struct.to_s
    end

    private

    def parse_name(n)
      if @struct_names.include? n
        i = 2
        while @struct_names.include? "#{n}_#{i}"
          i += 1
        end
        "#{n}_#{i}"
      else
        n
      end
    end

    def possible_new_struct(s)
      match = @structs.find{|st| s == st}
      s = match || s
      if match.nil?
        @structs << s
      end
      s
    end

    def parse_parts(name, values, struct)
      if values.is_a? Array
        struct = parse_array(name, values, struct)
      elsif values.is_a? Hash
        n = parse_name(name.split('_').collect(&:capitalize).join)
        @struct_names << n
        s = possible_new_struct( parse_hash(n, values) )
        struct.add_value(name, s)
      else
        struct = parse_value(name, values, struct)
      end
      struct
    end

    def parse_hash(n, hash)
      struct = RustStruct.new(n)
      @struct_names << n
      hash.each do |name, values|
        struct = parse_parts(name, values, struct)
      end
      struct
    end

    def parse_array(name, values, struct)
      # binding.pry
      types = Set.new
      values.each do |v|
        types << v.class
      end
      fail("Cannot handle multi typed arrays") if types.count > 1
      struct.add_value(name, Array, types.to_a.first)
      struct
    end

    def parse_value(name, value, struct)
      struct.add_value(name, value.class)
      struct
    end
  end
end