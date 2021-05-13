require "microtest"

require "../src/kommando"

# class TestContext
#   getter called = Hash(String, Kommando::Command(self)).new

#   def record(cmd : Kommando::Command(self))
#     @called[cmd.class.name] = cmd
#   end
# end

include Microtest::DSL
Microtest.run!
