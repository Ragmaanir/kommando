require "colorize"

module Kommando
  module Interaction
    class Session
      CONFIRM = %w{Y y Yes yes}
      DENY    = %w{N n No no}

      @io : IO
      delegate gets, to: @io

      getter? colorize : Bool

      def self.define(io : IO, colorize : Bool = true)
        s = new(io, colorize)
        with s yield(s)
      end

      def initialize(@io, @colorize = true)
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
          w("%2d" % (i + 1), fg: :cyan)
          w(" : ")
          w(("%8s" % key), fg: :cyan)
          if desc
            w(" : ")
            w(desc, fg: :dark_gray)
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
        ask(text) { |answer|
          case answer
          when .in?(CONFIRM) then true
          when .in?(DENY)    then false
          end
        }
      end

      def read_string_once
        gets || ""
      end

      def read_once(type : Int32.class | Float32.class)
        s = read_string_once

        case type
        when Int32.class   then s.to_i?
        when Float32.class then s.to_f32?
        end
      end

      def print_question(q : String)
        w(q, "\n", fg: :blue)
      end

      def print_input_marker
        w("> ", fg: :yellow)
      end

      def br
        w("\n")
      end

      def colorized_io(fg : Symbol? = nil, bg : Symbol? = nil, m : Colorize::Mode? = nil)
        if colorize?
          c = Colorize.with
          c = c.fore(fg) if fg
          c = c.mode(m) if m
          c = c.back(bg) if bg

          c.surround(@io) do |cio|
            yield cio
          end
        else
          yield @io
        end
      end

      def w(*strs : String | Int32 | Nil, fg : Symbol? = nil, bg : Symbol? = nil, m : Colorize::Mode? = nil)
        colorized_io(fg, bg, m) do |cio|
          strs.each { |s| cio << s }
        end
      end
    end
  end
end
