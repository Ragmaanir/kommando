require "colorize"
require "./kommando/version"
require "./kommando/errors"
require "./kommando/parser"
require "./kommando/docker"
require "./kommando/command"
require "./kommando/namespace"

module Kommando
  ROOT = Path.new(__DIR__).parent

  annotation Option
  end

  annotation Argument
  end

  TRUE_VALUES  = %w{true yes}
  FALSE_VALUES = %w{false no}

  ARG_PARSERS = {
    "Int32":  ->(s : String) { Int32.new(s) },
    "String": ->(s : String) { s },
    "Bool":   ->(s : String) {
      case s.downcase
      when TRUE_VALUES  then true
      when FALSE_VALUES then false
      else                   raise ArgumentError.new("Expected one of #{TRUE_VALUES + FALSE_VALUES}")
      end
    },
  }

  def self.bug(msg : String)
    raise "Kommando BUG: #{msg}"
  end
end
