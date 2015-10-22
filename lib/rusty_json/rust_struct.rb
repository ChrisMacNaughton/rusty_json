module RustyJson
  class RustStruct
    attr_reader :name, :values, :root

    @@types = {
      String => 'String',
      Fixnum => 'i64',
      Float => 'f64',
      Array => 'Vec',
    }

    def initialize(name, root = false)
      @root = root
      @printed = false
      @name = name
      @values = {}
      @structs = Set.new
    end

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

    def required_structs
      struct = ""
      # binding.pry
      @structs.to_a.each do |nested_struct|
        struct << nested_struct.to_s + "\n"
      end
      struct
    end

    def == other
      self.values == other.values
    end

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

    def self.add_type(name, value)
      @@types[name] = value
    end

    def self.type_name(type)
      @@types[type]
    end
  end
end