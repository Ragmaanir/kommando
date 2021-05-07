module Kommando
  module Parser
    def self.parse_args(original_args : Array(String))
      args = original_args.dup

      options = {} of String => String
      positional = [] of String

      while arg = args.shift?
        name = case arg
               when .starts_with?("--")  then arg[2..-1]
               when .starts_with?(/-\w/) then arg[1..-1]
               end

        if name
          if !args.empty? && !args[0].starts_with?("-")
            options[name] = args.shift
          else
            options[name] = ""
          end
        else
          positional << arg
        end
      end

      {options: options, positional: positional}
    end
  end
end
