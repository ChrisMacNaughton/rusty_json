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
      TrueClass => 'bool',
      FalseClass => 'bool',
      Array => 'Vec',
      NilClass => 'Option<?>'
    }
    # @param name [String] the name of the returned struct
    # @param root [Boolean] is this the root struct
    #
    # Root is used so that we can reset child structs when the to_s is finished
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
      @structs.each(&:reset)
    end

    # Add Value is how we add keys to the resulting Struct
    # We need a name and a type, and potentially a subtype
    #
    # For example:
    # types could be String, Fixnum, or Array
    # If the tyoe is Array, then we need the subtype of the array,
    # is it an array of integers or strings?
    #
    # @param name [String] what is this key in the struct
    # @param type [Class] What typs are we
    # @param subtype [Class] What typs are we
    #
    # @return true

    def add_value(name, type, subtype = nil)
      if type.class == RustyJson::RustStruct || subtype.class == RustyJson::RustStruct
        if type.class == RustyJson::RustStruct
          t = type
          type = type.name
          struct = t
        elsif subtype.class == RustyJson::RustStruct
          s = subtype
          subtype = subtype.name
          struct = s
        end
        @structs << struct
        RustStruct.add_type(struct.name, struct.name)
      end
      @values[name] = [type, subtype]
      true
    end

    # two Rust structs are equal if all of their keys / value types are the same
    def ==(other)
      values == other.values
    end

    # to_s controlls how to display the RustStruct as a Rust Struct
    def to_s
      return '' if @printed
      @printed = true
      struct = required_structs
      members = @values.map do |key, value|
        type = RustStruct.type_name(value[0])
        subtype = RustStruct.type_name(value[1])
        # TODO: add option for pub / private
        #       Will this be a per field thing that is configurable from
        #       within the JSON or will it be configured on the parse command?
        member = "    pub #{key}: #{type}"
        member << "<#{subtype}>" unless value[1].nil?
        member
      end
      struct << "pub struct #{@name} {\n" + members.join(",\n") + ",\n}\n\n"
      struct = struct.gsub("\n\n\n", "\n\n")
      reset if @root
      struct
    end

    private

    def required_structs
      s = @structs.map(&:to_s).join("\n")
      return "" if s == "\n"
      s
    end

    def self.add_type(name, value)
      @@types[name] = value
    end

    def self.type_name(type)
      @@types[type]
    end
  end
end
