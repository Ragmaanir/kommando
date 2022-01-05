module Kommando
  module Parser
    OPTION_PATTERN = /-[a-zA-Z]/
    QUOTES         = /"'/

    # Parses:
    #
    # "first -a=1"
    # => {positional: ["first"], options: {"a" => 1}}
    #
    # "first -1 -b third"
    # => {positional: ["first", "-1", "third"], options: {"b" => nil}}
    #
    def self.call(original_args : Array(String)) : {positional: Array(String), options: Hash(String, String?)}
      args = original_args.dup

      options = {} of String => String?
      positional = [] of String

      while arg = args.shift?
        if arg.starts_with?(OPTION_PATTERN)
          parts = arg.split("=", 2)

          name = parts[0][1..-1]
          value_part = parts[1]?

          # remove quotes
          # TODO escaped quotes
          if (v = value_part) && v.starts_with?(QUOTES)
            value_part = v[1..-2]
          end

          options[name] = value_part
        else
          positional << arg
        end
      end

      {positional: positional, options: options}
    end
  end
end
