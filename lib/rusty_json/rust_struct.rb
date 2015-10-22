module RustyJson
  #RustyJson:L:RustStruct is the object that will be translated into
  # a Rust struct.
  #
  # @!attribute name
  #   @return [String] name of the struct
  # @!attribute values
  #   @return [Hash] sub objects in the struct
  # @!attribute root
  #   @return is this the root level JSON object?

  class RustStruct
    attr_reader :name, :values, :root

    @@types = {
      String => 'String',
      Fixnum => 'i64',
      Float => 'f64',
      Array => 'Vec',
    }
    # @param name [String] the name of the returned struct
    def initialize(name, root = false)
      @root = root
      @printed = false
      @name = name
      @values = {}
      @structs = Set.new
    end

    # reset must be called to print the struct again, as we don't want to
    # repeatedly print the same struct when it occurs recursively in the
    # input JSON
    def reset
      @printed = false
      @structs.each do |s|
        s.reset
      end
    end

    def add_value(name, type, subtype = nil)
      if type.class == RustyJson::RustStruct || subtype.class == RustyJson::RustStruct
        struct = if type.class == RustyJson::RustStruct
          t = type
          type = type.name
          t
        elsif subtype.class == RustyJson::RustStruct
          s = subtype
          subtype = subtype.name
          s
        end
        @structs << struct
        RustStruct.add_type(struct.name, struct.name)
        @values[name] = [type, subtype]
      else
        @values[name] = [type, subtype]
      end
    end

    # two Rust structs are equal if all of their keys / value types are the same
    def == other
      self.values == other.values
    end

    # to_s controlls how to display the RustStruct as a Rust Struct
    def to_s
      return "" if @printed
      @printed = true
      struct = required_structs
      # binding.pry
      struct << <<-RUST
struct #{@name} {
      RUST
      @values.each do |attr_name, type|
        if type[1] == nil
          struct += "  #{attr_name}: #{RustStruct.type_name(type[0])}"
        else
          struct += "  #{attr_name}: #{RustStruct.type_name(type[0])}<#{RustStruct.type_name(type[1])}>"
        end
        struct += ",\n"
      end
      struct << <<-RUST
}
      RUST
      if @root
        reset
      end
      struct
    end

    private

    def required_structs
      struct = ""
      # binding.pry
      @structs.to_a.each do |nested_struct|
        struct << nested_struct.to_s + "\n"
      end
      struct
    end

    def self.add_type(name, value)
      @@types[name] = value
    end

    def self.type_name(type)
      @@types[type]
    end
  end
end