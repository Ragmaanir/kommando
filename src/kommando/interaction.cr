require "colorize"

module Kommando
  module Interaction
    CONFIRM = %w{Y y Yes yes}
    DENY    = %w{N n No no}

    def ask(text : String, &block : String -> T?) : T forall T
      res = nil

      while res == nil
        print_question(text)
        print INPUT_MARKER
        s = read_string_once

        res = yield s
      end

      res.not_nil!
    end

    def ask(text : String, type : Int32.class | Float32.class) : Int32 | Float32
      res = nil

      while res == nil
        print_question(text)
        print INPUT_MARKER
        res = read_once(type)
      end

      res.not_nil!
    end

    def choose(text : String, options : Array({String, String})) : String
      print_question(text)

      options.each_with_index { |(key, desc), i|
        print ("%2d" % (i + 1)).colorize(:cyan)
        print " : "
        print ("%8s" % key).colorize(:cyan)
        print " : "
        puts desc.colorize(:dark_gray)
      }

      keys = options.map(&.[0])

      ask(text) { |a|
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
      print_question(text)

      options.each_with_index { |opt, i|
        print ("%2d" % (i + 1)).colorize(:cyan)
        print " : "
        puts(("%s" % opt).colorize(:dark_gray))
      }

      ask(text) { |a|
        if num = a.to_i?
          if o = options[num - 1]?
            o[0]
          end
        else
          a if options.includes?(a)
        end
      }
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
      puts q.colorize(:blue)
    end

    INPUT_MARKER = "> ".colorize(:yellow)
  end
end

module X
  extend Kommando::Interaction

  def self.run
    # age = ask("What is your age?") { |s|
    #   s.to_i?
    # }
    age = ask("Age?", Int32)

    name = choose("Choose a character", [
      {"Wizard", "Can use magic spells"},
      {"Archer", "Shoots arrows over a long distance"},
      {"Knight", "Very strong armor, only melee fighting"},
    ])

    c = confirm("Want to exit #{name}?")
  end
end

X.run
