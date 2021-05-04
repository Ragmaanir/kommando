module Kommando
  abstract class Command
    macro option(name, type, **options)
      option({{name}}, {{type}}, nil, {{**options}})
    end

    macro option(name, type, desc, **options)
      {% default = options[:default] %}
      @[Kommando::Option(
        type: {{type}},
        desc: {{desc}},
        {% if !default.is_a?(NilLiteral) %}
          default: case {{default}}
            when Proc then {{default}}.as(Proc)
            else ->() { {{default}} }
          end,
        {% end %}

        {% for k, v in options %}
          {% if k != "default" %}
            {{k}}: {{v}},
          {% end %}
        {% end %}
      )]
      @{{name.id}} : {{type}} | Nil

      def {{name.id}}
        @{{name.id}}
      end
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

      {% verbatim do %}
      OPTION_PARSERS = {% begin %}
          {
            __empty: true, # cannot create an empty literal, so add this ignored key
            {% for var in @type.instance_vars %}
              {% if ann = var.annotation(Kommando::Option) %}
                {% type = ann.named_args[:type] %}

                {{var.name}}: ->(raw_val : String?) {
                  validator = {{ann.named_args[:validate]}} || ->(v : {{type}}?){ true }

                  value = if raw_val
                    Kommando::ARG_PARSERS[{{type}}].call(raw_val).as({{type}})
                  else
                    if default = {{ann.named_args[:default]}}
                      default.call
                    end
                  end

                  if !value.nil?
                    res = validator.call(value)

                    if ![true, nil].includes?(res)
                      raise Kommando::ValidationError.new("{{var.name}}", res.to_s)
                    end
                  end

                  value
                },
              {% end %}
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
                  __empty: true, # cannot create an empty literal, so add this ignored key
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

            options = NamedTuple.new(
              {% for var in @type.instance_vars %}
                {% if var.annotation(Kommando::Option) %}
                  {% sn = var.name.stringify %}
                  {{var.name}}: OPTION_PARSERS[{{sn}}].call(raw_options[{{sn}}]?),
                {% end %}
              {% end %}
            )

            new(**options).call
          {% end %}
        end

        def self.execute(**options)
          new(**options).call
        end

        def initialize(**options)
          {% for v in @type.instance_vars %}
            {% if ann = v.annotation(Kommando::Option) %}
              {%
                name = v.name.id
                default = ann.named_args[:default]
              %}

              {% if default.is_a?(NilLiteral) %}
                @{{name}} = options[:{{name}}]
              {% else %}
                if options.has_key?(:{{name}})
                  @{{name}} = options[:{{name}}]?
                else
                  @{{name}} = {{default}}.call
                end
              {% end %}
            {% end %}
          {% end %}
        end
      {% end %}
    end # included

  end # Command

end