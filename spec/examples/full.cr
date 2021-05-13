class Create < Kommando::Command(Nil)
  def call
  end
end

test do
  ctx = nil

  root = Kommando::Namespace.root(ctx) do
    namespace("db") do
      commands Create
    end
  end

  assert root.commands.keys == ["create"]
  assert root.namespaces.keys == ["db"]

  root.run(["db", "create"])
end
