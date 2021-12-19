require "./spec_helper"

describe Kommando::Namespace do
  class Ctx
    getter execution_log = [] of String
  end

  class Create < Kommando::Command(Ctx)
    def call
      context.execution_log << self.command_name
    end
  end

  class Migrate < Kommando::Command(Ctx)
    def call
      context.execution_log << self.command_name
    end
  end

  test do
    ctx = Ctx.new

    root = Kommando::Namespace.root(ctx) do
      commands Create

      namespace("db") do
        command Create
        command Migrate
      end
    end

    assert root.commands.keys == ["create"]
    assert root.namespaces.keys == ["db"]

    root.run(["db", "create"])
    root.run(["db", "migrate"])

    assert ctx.execution_log == ["create", "migrate"]
  end
end
