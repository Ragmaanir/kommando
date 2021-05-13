require "colorize"
require "./kommando/*"

module Kommando
  annotation Option
  end

  annotation Params
  end

  ARG_PARSERS = {
    "Int32":  ->(s : String) { Int32.new(s) },
    "String": ->(s : String) { s },
    "Bool":   ->(s : String) { !s.in?(%w{false no}) },
  }

  class ValidationError < Exception
    def initialize(prop : String, result)
      super("Validation for property #{prop} failed with #{result}")
    end
  end

  def self.bug(msg : String)
    raise "Kommando BUG: #{msg}"
  end
end
