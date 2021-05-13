require "./spec_helper"

describe Kommando::Namespace do
  class Ctx
    property cmd : Kommando::Command(self)?
  end

  class Create < Kommando::Command(Ctx)
    def call
    end
  end

  class Migrate < Kommando::Command(Ctx)
    def call
    end
  end

  test do
    ctx = Ctx.new

    root = Kommando::Namespace.root(ctx) do
      commands Create
      namespace("db") do
        # commands Create, Migrate, Drop, Dump
        commands Create, Migrate
      end
    end

    assert root.commands.keys == ["create"]
    assert root.namespaces.keys == ["db"]

    root.run(["db", "create"])
  end
end
