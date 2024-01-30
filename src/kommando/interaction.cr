require "colorize"

module Kommando
  module Interaction
    class Session
      CONFIRM = %w{y yes}
      DENY    = %w{n no}

      @outp : IO
      @inp : IO

      getter? colorize : Bool

      def self.define(outp : IO = STDOUT, inp : IO = STDIN, colorize : Bool = true)
        s = new(outp, inp, colorize)
        with s yield(s)
      end

      def initialize(@outp, @inp, @colorize = true)
      end

      private def print_question(q : String)
        wl(q, fg: CYAN)
      end

      private def print_input_marker
        w("> ", fg: YELLOW)
      end

      def read_until(&block : String -> T?) : T forall T
        res = nil

        while res == nil
          print_input_marker
          s = read_string_once

          res = yield s
        end

        res.not_nil!
      end

      # TODO: ask with default

      def ask(text : String, &block : String -> T?) : T forall T
        print_question(text)

        read_until(&block)
      end

      def ask(text : String, type : Int32.class | Float32.class) : Int32 | Float32
        ask(text) do |s|
          case type
          when Int32.class   then s.to_i?
          when Float32.class then s.to_f32?
          end
        end
      end

      def choose(text : String, options : Array({String, String?})) : String
        print_question(text)

        options.each_with_index { |(key, desc), i|
          w("%2d" % (i + 1), fg: CYAN)
          w(" : ")
          w(("%8s" % key), fg: CYAN)
          if desc
            w(" : ")
            w(desc, fg: DARK_GRAY)
          end
          br
        }

        keys = options.map(&.[0])

        read_until { |a|
          if num = a.to_i?
            if o = options[num - 1]?
              o[0]
            end
          else
            a if keys.includes?(a)
          end
        }
      end

      def choose(text : String, options : Array(String)) : String
        choose(text, options.map { |s| {s, nil} })
      end

      def confirm(text : String, confirm : Array(String) = CONFIRM, deny : Array(String) = DENY)
        options = "[#{(CONFIRM + DENY).join(", ")}]"

        wl(text)
        wl(options, fg: LIGHT_GRAY)

        read_until { |answer|
          case answer.downcase
          when .in?(CONFIRM) then true
          when .in?(DENY)    then false
          else                    wl("Invalid input", fg: RED)
          end
        }
        # print_question(text + "[#{(CONFIRM + DENY).join(", ")}]")

        # read_until { |a|
        #   case a
        #   when .in?(CONFIRM) then true
        #   when .in?(DENY)    then false
        #   else                    print_question(text)
        #   end
        # }
      end

      def read_string_once
        @inp.gets || ""
      end

      def read_once(type : Int32.class | Float32.class)
        s = read_string_once

        case type
        when Int32.class   then s.to_i?
        when Float32.class then s.to_f32?
        end
      end

      def cancel(s : String = "Cancelled")
        wl(s, fg: YELLOW)
        exit 0
      end

      def abort(s : String)
        wl(s, fg: RED)
        exit 1
      end

      def br
        w("\n")
      end

      def colorized_io(fg : RGB? = nil, bg : RGB? = nil, m : Colorize::Mode? = nil)
        if colorize?
          c = Colorize.with
          c = c.fore(fg) if fg
          c = c.mode(m) if m
          c = c.back(bg) if bg

          c.surround(@outp) do |cio|
            yield cio
          end
        else
          yield @outp
        end
      end

      def w(*strs : String | Int32 | Nil, fg : RGB? = nil, bg : RGB? = nil, m : Colorize::Mode? = nil)
        colorized_io(fg, bg, m) do |cio|
          strs.each { |s| cio << s }
        end
      end

      def wl(*strs : String | Int32 | Nil, **options)
        # w(*strs + {"\n"}, **options)
        w(*strs, **options)
        br
      end
    end
  end
end
