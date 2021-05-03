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

  class ValidationError < Exception
    def initialize(*args)
      super
    end
  end

  abstract class Command
    macro option(name, type, **options)
      option({{name}}, {{type}}, "No description", {{**options}})
    end

    macro option(name, type, desc, **options)
      @[Kommando::Option(
        type: {{type}},
        desc: {{desc}},
        {{**options}}
      )]
      @{{name.id}} : {{type}} | Nil
    end

    macro argument(name, type, **options)
      # @{{name.id}} : {{type}}
    end

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

    macro inherited
      def self.command_name
        canonical_name.underscore
      end

      def self.canonical_name
        self.name.split("::").last
      end

      OPTION_PARSERS = {% verbatim do %}
        {% begin %}
          {%
            opt_vars = @type.instance_vars.select { |var| var.annotation(Kommando::Option) }
          %}

          {
            __empty: true, # cannot create an empty literal, so add this ignored key
            {% for var in opt_vars %}
              {%
                ann = var.annotation(Kommando::Option)
                type = ann.named_args[:type]
                validate = ann.named_args[:validate]
                default = ann.named_args[:default]
              %}

              {{var.name}}: ->(raw_val : String?) {
                  validator = {{validate}} || ->(v : {{type}}?){ true }

                  default = case {{default}}
                    when Proc then {{default}}.as(Proc)
                    else ->() { {{default}} }
                  end

                  value = if raw_val
                    Kommando::ARG_PARSERS[{{type}}].call(raw_val).as({{type}})
                  else
                    default.call
                  end

                  if !value.nil?
                    res = validator.call(value)

                    if ![true, nil].includes?(res)
                      raise Kommando::ValidationError.new("Validation for {{var.name}} failed: #{res}")
                    end
                  end

                  value
                },
            {% end %}
          }
        {% end %}
      {% end %}


      {% verbatim do %}
        def self.run_xxx(args : Array(String))
          {% begin %}
            # parse arguments
            # TODO

            raw_options = Kommando::Command.parse_args(args)

            options = {
              {% for name, parser in OPTION_PARSERS %}
                {% if name == "__empty" %}
                  __empty: true,
                {% else %}
                  {{name}}: {{parser}}.call(raw_options[{{name.stringify}}]?),
                {% end %}
              {% end %}
            }

            new(**options).call
          {% end %}
        end

        def self.run(args : Array(String))
          {% begin %}
            # parse arguments
            # TODO

            raw_options = Kommando::Command.parse_args(args)

            {%
              opt_vars = @type.instance_vars.select { |var| var.annotation(Kommando::Option) }
            %}

            options = NamedTuple.new(
              {% for var in opt_vars %}
                {% sn = var.name.stringify %}
                {{var.name}}: OPTION_PARSERS[{{sn}}].call(raw_options[{{sn}}]?),
              {% end %}
            )

            new(**options).call
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

  end # Command

  class Namespace
    getter name : String
    getter namespaces : Hash(String, Namespace) = Hash(String, Namespace).new
    getter commands : Hash(String, Command.class) = Hash(String, Command.class).new

    def self.build(name, &block)
      n = new(name)
      with n yield n
      n
    end

    def initialize(@name)
    end

    # def initialize(@name, &block)
    #   with self yield
    # end

    # macro namespace(name, &block)
    #   %n = Namespace.new({{name}})
    #   @namespaces[{{name}}] = %n
    #   with %n yield
    # end

    # XXX
    def namespace(name : String, &block)
      @namespaces[name] = Namespace.build(name) do |n|
        with n yield n
      end
    end

    # def namespace(name : String, &block)
    #   n = Namespace.new(name)
    #   @namespaces[name] = n
    #   with n yield
    # end

    # def namespace(name : String, &block)
    #   @namespaces[name] = Namespace.build(name) do
    #     with self yield
    #   end
    # end

    def commands(*cmds : Command.class)
      cmds.each do |cmd|
        @commands[cmd.command_name] = cmd
      end
    end

    def run(args : Array(String))
      args = args.dup
      arg = args.shift

      if cmd = commands[arg]?
        cmd.run(args)
      elsif ns = namespaces[arg]?
        ns.run(args)
      else
        raise "Unrecognized command or namespace: #{arg}"
      end
    end
  end
end
