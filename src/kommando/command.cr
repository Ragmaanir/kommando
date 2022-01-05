module Kommando
  module Command
    abstract def call

    macro option(*args, parse = nil, validate = nil, default = nil, __file = __FILE__, __line = __LINE__, **options)
      {%
        raise "Expected 3 arguments for option(...), got #{args.size} in #{__file.id}:#{__line}" if args.size != 3
        name = args[0]
        type = args[1]
        desc = args[2]
      %}
      @[Kommando::Option(
        type: {{type}},
        desc: {{desc}},
        short: {{options[:short] || name[0..0]}},
        default: (case %d = {{default}}
          when Proc then %d
          else ->() { %d }
        end),
        validate: ->(%v : {{type}}) {
          %res = ({{validate}} || ->(_v : {{type}}){ true }).call(%v)

          if ![true, nil].includes?(%res)
            raise Kommando::ValidationError.new("{{name.id}}", %res.to_s)
          end
        },
        parse: ({{parse}} || ->(%raw_val : String) {
          Kommando::ARG_PARSERS[{{type.stringify}}].call(%raw_val).as({{type}})
        }),

        {% for k, v in options %}
          {{k}}: {{v}},
        {% end %}
      )]
      @{{name.id}} : {{type}} | Nil

      getter {{name.id}}
    end

    macro arg(*args, parse = nil, validate = nil, __file = __FILE__, __line = __LINE__, **options)
      {%
        raise "Expected 2 arguments for arg(...), got #{args.size} in #{__file.id}:#{__line}" if args.size != 2
        name = args[0]
        type = args[1]
      %}
      @[Kommando::Argument(
        type: {{type}},
        validate: ->(%v : {{type}}) {
          %res = ({{validate}} || ->(_v : {{type}}){ true }).call(%v)

          if ![true, nil].includes?(%res)
            raise Kommando::ValidationError.new("{{name.id}}", %res.to_s)
          end
        },
        parse: {{parse}} || ->(%raw_val : String) {
          Kommando::ARG_PARSERS[{{type.stringify}}].call(%raw_val).as({{type}})
        },

        {% for k, v in options %}
          {{k}}: {{v}},
        {% end %}
      )]
      @{{name.id}} : {{type}}

      getter {{name.id}}
    end

    macro included
      def self.command_name
        name.split("::").last.underscore
      end

      delegate command_name, to: self.class

      {% verbatim do %}
      macro finished
        {% verbatim do %}

        def self.call(args : Array(String))
          {% begin %}
          %pair = Kommando::Parser.call(args)

          %positional_args = %pair[:positional]

          {% i = 0 %}
          %parsed_pos_args = Tuple.new(
            {% for var in @type.instance_vars %}
              {% if ann = var.annotation(Kommando::Argument) %}
                {% a = ann.named_args %}
                begin
                  raise Kommando::MissingArgumentError.new("{{var.name}}") if {{i}} >= %positional_args.size
                  %value = {{a[:parse]}}.call(%positional_args[{{i}}])

                  {{a[:validate]}}.call(%value)

                  %value
                  {% i += 1 %}
                end,
              {% end %}
            {% end %}
          )

          if %parsed_pos_args.size != %positional_args.size
            unexpected = %positional_args[%parsed_pos_args.size..-1]
            raise Kommando::UnexpectedArgumentsError.new(unexpected)
          end

          %options = %pair[:options]

          %parsed_options = NamedTuple.new(
            {% for var in @type.instance_vars %}
              {% name = var.name %}
              {% if ann = var.annotation(Kommando::Option) %}
                {% a = ann.named_args %}
                {{name}}: begin
                  %raw_value = %options[{{name.stringify}}]?

                  {{a[:parse]}}.call(%raw_value) if %raw_value
                end,
              {% end %}
            {% end %}
          )

          new(*%parsed_pos_args, **%parsed_options).call
          {% end %}
        end # self.call

        def initialize(*args, **options)
          # positional arguments
          {% begin %}
            {% i = 0 %}
            {% for v in @type.instance_vars %}
              {% name = v.name.id %}
              {% if ann = v.annotation(Kommando::Argument) %}
                @{{name}} = args[{{i}}]
                {% i += 1 %}
              {% end %}
            {% end %}
          {% end %}

          # options
          {% for v in @type.instance_vars %}
            {% name = v.name.id %}
            {% if ann = v.annotation(Kommando::Option) %}
              {% default = ann.named_args[:default] %}

              %value = options[:{{name}}]? || {{default}}.call

              case %v = %value
              when nil
              else
                {{ann.named_args[:validate]}}.call(%v)

                @{{name}} = %v
              end
            {% end %}
          {% end %}
        end # initialize
        {% end %}
      end # finished
      {% end %}
    end # inherited
  end
end
