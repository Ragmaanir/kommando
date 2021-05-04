require "colorize"
require "./kommando/*"

module Kommando
  VERSION = {{ `shards version #{__DIR__}`.strip.stringify }}

  annotation Option
  end

  ARG_PARSERS = {
    Int32  => ->(s : String) { Int32.new(s) },
    String => ->(s : String) { s },
    Bool   => ->(s : String) { s != nil },
  }

  class ValidationError < Exception
    def initialize(prop : String, result)
      super("Validation for property #{prop} failed with #{result}")
    end
  end
end
