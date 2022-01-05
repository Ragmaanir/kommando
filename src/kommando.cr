require "colorize"
require "./kommando/*"

module Kommando
  annotation Option
  end

  annotation Argument
  end

  ARG_PARSERS = {
    "Int32":  ->(s : String) { Int32.new(s) },
    "String": ->(s : String) { s },
    "Bool":   ->(s : String) { !s.in?(%w{false no}) },
  }

  abstract class KommandoException < Exception
  end

  class MissingArgumentError < KommandoException
    def initialize(arg : String)
      super("Missing argument: '#{arg}'")
    end
  end

  class UnexpectedArgumentsError < KommandoException
    def initialize(args : Array(String))
      super("Unexpected arguments: #{args.join(", ")}")
    end
  end

  class ValidationError < KommandoException
    def initialize(prop : String, result)
      super("Validation for property #{prop} failed with #{result}")
    end
  end

  def self.bug(msg : String)
    raise "Kommando BUG: #{msg}"
  end
end
