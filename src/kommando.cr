require "colorize"
require "./kommando/*"

module Kommando
  VERSION = {{ `shards version #{__DIR__}`.strip.stringify }}

  annotation Option
  end

  ARG_PARSERS = {
    Int32  => ->(s : String) { Int32.new(s) },
    String => ->(s : String) { s },
    Bool   => ->(s : String) { s != nil },
  }

  module Command
    macro included
      {% verbatim do %}
        def self.run(args : Array(String))
          {% begin %}
            {%
              opt_vars = @type.instance_vars.select { |var| var.annotation(Kommando::Option) }
            %}

            # parse arguments
            # TODO

            raw_options = Kommando::Command.parse_options(args)

            {% if opt_vars.empty? %}
              new.call
            {% else %}
              options = {
                {% for var in opt_vars %}
                  {%
                    ann = var.annotation(Kommando::Option)
                    type = ann.named_args[:type]
                    validate = ann.named_args[:validate]
                    default = ann.named_args[:default]
                  %}

                  {{var.name}}: begin
                      validator = {{validate}} || ->(v : {{type}}?){ true }

                      default = case {{default}}
                      when Proc then {{default}}.as(Proc)
                      else ->() { {{default}} }
                      end

                      raw_val = raw_options[{{var.name.stringify}}]?

                      value = if raw_val
                        Kommando::ARG_PARSERS[{{type}}].call(raw_val).as({{type}})
                      else
                        default.call
                      end

                      res = validator.call(value)

                      if ![true, nil].includes?(res)
                        raise "Validation failed: #{res}"
                      end

                      value
                    end,
                {% end %}
              }

              new(**options).call
            {% end %}

            {% debug %}
          {% end %}
        end

        def initialize(**options)
          {% begin %}
            {%
              opt_vars = @type.instance_vars.select { |var|
                var.annotation(Kommando::Option)
              }
            %}

            {% for v in opt_vars %}
              @{{v.name.id}} = options[:{{v.name.id}}]
            {% end %}
          {% end %}
        end
      {% end %}
    end # included

    macro option(name, type, **options)
      option({{name}}, {{type}}, "No description", {{**options}})
    end

    macro option(name, type, desc, **options)
      @[Kommando::Option(type: {{type}}, description: {{desc}})]
      @{{name.id}} : {{type}} | Nil
    end

    macro argument(name, type, **options)
      # @{{name.id}} : {{type}}
    end

    def self.parse_options(original_args : Array(String))
      args = original_args.dup

      raw_options = {} of String => String

      while raw_arg = args.shift?
        arg_name = case raw_arg
                   when .starts_with?("--")  then raw_arg[2..-1]
                   when .starts_with?(/-\w/) then raw_arg[1..-1]
                   else                           raise %[Could not parse argument: #{raw_arg.inspect.colorize(:red)} in #{original_args.inspect.colorize(:blue)}]
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

  # command "" do
  # end

  # @[Command]
  # class MyCmd
  #   include Command

  #   @[Option(desc: "Description")]
  #   getter force : Bool = false

  #   option(force, Bool, "Description", default: false)
  #   option(email, Email, "") do |str|
  #     # parse
  #   end

  #   def call
  #   end
  # end
end

class App
  class Cmd
    class Argument
    end

    getter name : String
    getter args : Hash(String, Argument)
    getter children : Array(Cmd)
    getter block : CmdPart ->

    def initialize(@name, @args = {} of String => Argument, @children = [] of Cmd, &@block)
    end

    def call(arg : CmdPart)
      @block.call(arg)
    end
  end

  record(CmdPart, name : String, args : Array(String) = Array(String).new)

  def run
    parts = [] of CmdPart

    ARGV.each do |arg|
      case arg
      when /\A[a-zA-Z0-9]/
        parts.push(CmdPart.new(arg, [] of String))
      when /\A-/
        parts.last.args.push(arg)
      else raise "Unhandled argument: #{arg}"
      end
    end

    cmd = Cmd.new("build", children: [
      Cmd.new,
    ])
  end
end
