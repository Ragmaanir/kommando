module Kommando
  abstract class KommandoException < Exception
  end

  class MissingArgumentError < KommandoException
    getter arg : String
    getter type : String

    def initialize(@arg, @type)
      super("Missing argument: '#{arg}' (#{type})")
    end
  end

  class UnexpectedArgumentsError < KommandoException
    getter args : Array(String)

    def initialize(@args)
      super("Unexpected arguments: #{args.join(", ")}")
    end
  end

  class ValidationError < KommandoException
    getter prop : String
    getter type : String
    getter value : String
    getter result : String?

    def initialize(@prop, @type, @value, @result)
      super("Validation for '#{prop}' (#{type}) failed: #{value.inspect} (#{result})")
    end
  end

  class DuplicateOptionError < KommandoException
    getter long : String
    getter short : String

    def initialize(@long, @short)
      super("Duplicate options: -#{long}, -#{short}")
    end
  end

  class UnknownOptionError < KommandoException
    getter name : String

    def initialize(@name)
      super("Unknown option: -#{name}")
    end
  end
end
