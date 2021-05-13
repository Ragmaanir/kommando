class Create < Kommando::Command(Nil)
  def call
  end
end

class Migrate < Kommando::Command(Nil)
  def call
  end
end

test do
  ctx = nil

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
