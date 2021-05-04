module Kommando
  module Parser
    def self.parse_args(original_args : Array(String))
      args = original_args.dup

      raw_options = {} of String => String

      while raw_arg = args.shift?
        arg_name = case raw_arg
                   when .starts_with?("--")  then raw_arg[2..-1]
                   when .starts_with?(/-\w/) then raw_arg[1..-1]
                   else
                     raise %[Could not parse argument: #{raw_arg.inspect.colorize(:red)} in #{original_args.inspect.colorize(:blue)}]
                   end

        if !args.empty? && !args[0].starts_with?("-")
          raw_options[arg_name] = args.shift
        else
          raw_options[arg_name] = ""
        end
      end

      raw_options
    end
  end
end
