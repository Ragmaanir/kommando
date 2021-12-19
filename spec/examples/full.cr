class Ctx
end

class Create < Kommando::Command(Ctx)
  def call
  end
end

class UnrelatedCmd < Kommando::Command(Nil)
  def call
  end
end

test do
  ctx = Ctx.new

  root = Kommando::Namespace.root(ctx) do
    namespace("db") do
      command Create
      command UnrelatedCmd
    end
  end

  assert root.namespaces["db"].commands.keys == ["create", "unrelated_cmd"]
  assert root.namespaces.keys == ["db"]

  root.run(["db", "create"])
end
