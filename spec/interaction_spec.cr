require "./spec_helper"
require "../src/kommando/interaction"

describe Kommando::Interaction::Session do
  class CannedIO < IO
    class Builder
      getter actions = Array({Symbol, String}).new

      def write(s : String)
        @actions << {:write, s}
      end

      def read(s : String)
        @actions << {:read, s}
      end
    end

    def self.build
      b = Builder.new
      with b yield
      new(b.actions)
    end

    @action_idx = 0
    @string_idx = 0

    def initialize(@actions : Array({Symbol, String}))
    end

    private def current_action
      @actions[@action_idx]
    end

    private def advance
      @action_idx += 1
      @string_idx = 0
    end

    def read(slice : Bytes)
      # STDOUT.puts ".read(#{current_action[1].inspect})"
      raise "Expected :read, got #{current_action[0]}" if current_action[0] != :read

      slice.size.times { |i|
        slice[i] = current_action[1].byte_at(@string_idx)
        @string_idx += 1
      }
      advance if current_action[1].size == @string_idx
      slice.size
    end

    def write(slice : Bytes) : Nil
      # STDOUT.puts ".write(#{String.new(slice).inspect})"
      raise "Expected :write, got #{current_action[0]}" if current_action[0] != :write
      # raise "Invalid length: #{current_action[1].inspect} <=> #{String.new(slice).inspect}" if current_action[1].size != slice.size

      slice.size.times { |i|
        if slice[i] != current_action[1].byte_at(@string_idx)
          raise "Unexpected output: #{String.new(slice).inspect} != #{current_action[1].inspect}"
        end
        @string_idx += 1
      }
      advance if current_action[1].size == @string_idx
    end
  end

  def session(io, colorize = false)
    Kommando::Interaction::Session.define(io, io, colorize) do |s|
      with s yield(s)
    end
  end

  test "read_until" do
    io = CannedIO.build do
      write "> "
      read "a\n"
      write "> "
      read "\n"
      write "> "
      read "stop\n"
    end

    session(io) do
      res = read_until do |s|
        "ok" if s == "stop"
      end
      assert res == "ok"
    end
  end

  test "ask with invalid input" do
    io = CannedIO.build do
      write "Age?\n"
      write "> "
      read "hello\n"
      write "> "
      read "\n"
      write "> "
      read "1\n"
    end

    session(io) do
      age = ask("Age?", Int32)
      assert age == 1
    end
  end

  test "choose" do
    io = CannedIO.build do
      write "Choose a character\n"
      write " 1 :   Wizard : Can use magic spells\n"
      write " 2 :   Archer : Shoots arrows over a long distance\n"
      write " 3 :   Knight : Very strong armor, only melee fighting\n"
      write "> "
      read "1\n"
    end

    session(io) do
      name = choose("Choose a character", [
        {"Wizard", "Can use magic spells"},
        {"Archer", "Shoots arrows over a long distance"},
        {"Knight", "Very strong armor, only melee fighting"},
      ])

      assert name == "Wizard"
    end
  end

  test "choose simplified" do
    io = CannedIO.build do
      write "Choose a character\n"
      write " 1 :   Wizard\n"
      write " 2 :   Archer\n"
      write " 3 :   Knight\n"
      write "> "
      read "1\n"
    end

    session(io) do
      name = choose("Choose a character", [
        "Wizard",
        "Archer",
        "Knight",
      ])

      assert name == "Wizard"
    end
  end

  test "confirm" do
    io = CannedIO.build do
      write "Want to exit?\n"
      write "[y, yes, n, no]\n"
      write "> "
      read "n\n"
    end

    session(io) do
      c = confirm("Want to exit?")

      assert c == false
    end
  end
end
