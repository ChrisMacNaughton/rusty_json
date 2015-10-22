require 'json'
require 'set'
require 'pry'

module RustyJson
  class Parser
    BASE_TYPES = {
      String => 'String',
      Fixnum => 'i64',
      Float => 'f64',
    }

    def initialize(name, json)
      @name = name
      @json = json
      @struct_names = Set.new
      @structs = Set.new
    end

    def parse
      @parsed = JSON.parse(@json)
      struct = RustStruct.new(@name)
      if @parsed.is_a? Hash
        struct = parse_hash(@parsed, struct)
      end
      struct.to_s
    end

    private

    def parse_parts(name, values, struct)
      if values.is_a? Array
        struct = parse_array(name, values, struct)
      elsif values.is_a? Hash
        n = name.split('_').collect(&:capitalize).join
        # binding.pry if n.include? 'Key'
        n = if @struct_names.include? n
          parts = n.split('_')
          if parts.count > 1
            "#{parts[0]}_#{parts[1].to_i + 1}"
          else
            n + "_2"
          end
        else
          n
        end
        @struct_names << n
        s = RustStruct.new(n)
        s = parse_hash(values, s)
        match = @structs.find{|st| s == st}
        s = match || s
        if match.nil?
          @struct_names << n
          @structs << s
        end
        struct.add_value(name, s)
      else
        struct = parse_value(name, values, struct)
      end
      struct
    end

    def parse_hash(hash, struct)
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