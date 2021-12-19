module Kommando
  abstract class BaseCommand
  end

  abstract class Command(C) < BaseCommand
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
      @{{name.id}} : {{type}} {% if default.is_a?(NilLiteral) %}| Nil{% end %}

      def {{name.id}}
        @{{name.id}}
      end
    end

    macro inherited
      def self.command_name
        name.split("::").last.underscore
      end

      delegate command_name, to: self.class

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
                    Kommando::ARG_PARSERS[{{type.stringify}}].call(raw_val).as({{type}})
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

            raw_options = Kommando::Parser.parse_args(args)

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

        def self.run(context : C, args : Array(String))
          {% begin %}
            pair = Kommando::Parser.parse_args(args)
            raw_options = pair[:options]
            positional_args = pair[:positional]

            options = NamedTuple.new(
              {% for var in @type.instance_vars %}
                {% if var.annotation(Kommando::Option) %}
                  {% sn = var.name.stringify %}
                  {{var.name}}: OPTION_PARSERS[{{sn}}].call(raw_options[{{sn}}]?),
                {% end %}
              {% end %}
            )

            new(context, **options).run(positional_args)
          {% end %}
        end

        def self.execute(context : C, *args : String, **options)
          new(context, **options).run(args.to_a)
        end

        def self.execute(context : C, args : Array(String) = [] of String, **options)
          new(context, **options).run(args)
        end

        def run(args : Array(String))
          {% begin %}
            {%
              call_meths = @type.methods.select(&.name.==("call"))
              raise "Kommando: Overloading Command#call is not allowed" if call_meths.size > 1
              meth = call_meths.first
            %}

            {% if meth.args.size == 0 %}
              call
            {% else %}
              args = {
                {% for arg in meth.args %}
                  {{arg.name}}: begin
                    parser = Kommando::ARG_PARSERS[{{arg.restriction.stringify}}]
                    arg = args.shift? || raise "{{@type.name}}.run: Argument missing: {{arg.name}} : {{arg.restriction}}"
                    parser.call(arg)
                  end,
                {% end %}
              }

              call(**args)
            {% end %}
          {% end %}

          # self
          # https://github.com/crystal-lang/crystal/issues/10911
          nil
        end

        getter context : C

        def initialize(@context, **options)
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
                  @{{name}} = options[:{{name}}]?.not_nil!
                else
                  @{{name}} = {{default}}.call
                end
              {% end %}
            {% end %}
          {% end %}
        end
      {% end %}
    end # included
  end   # Command

  # class Cmd < Command(Nil)
  #   def self.run(args : Array(String))
  #     run(nil, args)
  #   end

  #   def self.execute(*args : String, **options)
  #     new(nil, **options).run(args.to_a)
  #   end

  #   def self.execute(args : Array(String) = [] of String, **options)
  #     new(nil, **options).run(args)
  #   end

  #   def initialize(**options)
  #     initialize(nil, **options)
  #   end
  # end
end
