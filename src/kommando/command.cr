module Kommando
  module Command
    module Meta
      def description : String
        "No description"
      end

      def call(args : Array(String))
      end
    end

    abstract def call

    macro option(*args, parse = nil, validate = nil, default = nil, __file = __FILE__, __line = __LINE__, **options)
      {%
        raise "Expected 3 arguments for option(...), got #{args.size} in #{__file.id}:#{__line}" if args.size != 3
        name = args[0]
        type = args[1]
        desc = args[2]
      %}
      @[Kommando::Option(
        name: {{name}},
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
            raise Kommando::ValidationError.new("{{name.id}}", "{{type.id}}", %v.to_s, %res.to_s)
          end
        },
        parse: ({{parse}} || ->(%raw_val : String) {
          begin
            Kommando::ARG_PARSERS["{{type.id}}"].call(%raw_val).as({{type}})
          rescue e
            raise Kommando::ValidationError.new("{{name.id}}", "{{type.id}}", %raw_val.to_s, e.message)
          end
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
        name: {{name}},
        type: {{type}},
        validate: ->(%v : {{type}}) {
          %res = ({{validate}} || ->(_v : {{type}}){ true }).call(%v)

          if ![true, nil].includes?(%res)
            raise Kommando::ValidationError.new("{{name.id}}", "{{type.id}}", %v.to_s, %res.to_s)
          end
        },
        parse: {{parse}} || ->(%raw_val : String) {
          begin
            Kommando::ARG_PARSERS["{{type.id}}"].call(%raw_val).as({{type}})
          rescue e
            raise Kommando::ValidationError.new("{{name.id}}", "{{type.id}}", %raw_val.to_s, e.message)
          end
        },

        {% for k, v in options %}
          {{k}}: {{v}},
        {% end %}
      )]
      @{{name.id}} : {{type}}

      getter {{name.id}}
    end

    macro included
      extend Kommando::Command::Meta

      def self.command_name
        name.split("::").last.underscore
      end

      delegate command_name, to: self.class

      {% verbatim do %}
      macro finished
        {% verbatim do %}

        def self.positionals
          {% begin %}
          {% i = 0 %}
          Tuple.new(
            {% for var in @type.instance_vars %}
              {% if ann = var.annotation(Kommando::Argument) %}
                { pos: {{i}}, {{ann.named_args.double_splat}} },
                {% i += 1 %}
              {% end %}
            {% end %}
          )
          {% end %}
        end

        def self.options
          {% begin %}
          NamedTuple.new(
            {% for var in @type.instance_vars %}
              {% if ann = var.annotation(Kommando::Option) %}
                {{var.name.id}}: {{ann.named_args}},
              {% end %}
            {% end %}
          )
          {% end %}
        end

        def self.describe(io : IO)
          io << command_name.colorize(Kommando::YELLOW)
          io << ": "
          io.puts description.colorize(Kommando::DARK_GRAY)
          io.puts

          io << "Usage: "
          describe_usage(io)
          io.puts
          io.puts

          io.puts "Positional:"
          describe_positionals(io)
          io.puts

          io.puts "Options:"
          describe_options(io)
          io.puts
        end

        def self.describe_usage(io : IO)
          io << command_name.colorize(Kommando::YELLOW)
          io << " "

          positionals.join(io, " ") { |a, io|
            io << a[:name].colorize(Kommando::LIGHT_BLUE)
          }

          io << " "
          io << "-option=value".colorize(Kommando::DARK_GRAY)
        end

        def self.describe_positionals(io : IO)
          positionals.each { |a|
            io << ("  %-10s" % a[:name]).colorize(Kommando::LIGHT_BLUE)
            io << " : "
            io << ("%-8s" % a[:type]).colorize(Kommando::MAGENTA)
            io.puts
          }
        end

        def self.describe_options(io : IO)
          options.each { |name, o|
            io << ("  %-10s " % name).colorize(Kommando::LIGHT_BLUE)

            shortcut = ""
            shortcut = ("-" + o[:short].to_s) if o[:short]

            io << "%-2s" % shortcut.colorize(Kommando::CYAN)

            io << " : "
            io << ("%-8s" % o[:type]).colorize(Kommando::MAGENTA)
            io << " "
            io << o[:desc].colorize(Kommando::DARK_GRAY)
            io.puts
          }
        end

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
                  if {{i}} >= %positional_args.size
                    raise Kommando::MissingArgumentError.new("{{var.name}}", "{{var.type}}")
                  end
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

          {%
            option_vars = [] of Tuple(Crystal::MetaVar, Kommando::Option)

            @type.instance_vars.each do |var|
              if ann = var.annotation(Kommando::Option)
                option_vars << {var, ann}
              end
            end

            encountered_options = [] of String
          %}

          %parsed_options = NamedTuple.new(
            {% for pair in option_vars %}
              {%
                var, ann = pair
                a = ann.named_args
                n = a[:name].id.stringify
                s = a[:short].id.stringify
                encountered_options << n
                encountered_options << s
              %}
              {{var.name}}: begin
                %name = {{n}}
                %short = {{s}}
                %parse = {{a[:parse]}}

                if %options.has_key?(%name) && %options.has_key?(%short)
                  raise Kommando::DuplicateOptionError.new(%name, %short)
                elsif %options.has_key?(%name)
                  if %raw_value = %options[%name]?
                    %parse.call(%raw_value)
                  end
                elsif %options.has_key?(%short)
                  if %raw_value = %options[%short]?
                    %parse.call(%raw_value)
                  end
                end
              end,
            {% end %}
          )

          if unknown = %options.keys.find { |k| !({{encountered_options}} of String).includes?(k) }
            raise Kommando::UnknownOptionError.new(unknown)
          end

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
              {% a = ann.named_args %}
              {% default = a[:default] %}

              %value = options[:{{name}}]?

              if %value == nil
                %value = {{default}}.call
              end

              # if !options.has_key?(:{{name}})
              #   %value = { {default}}.call
              # end

              case %v = %value
              when nil
              else
                {{a[:validate]}}.call(%v)
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
