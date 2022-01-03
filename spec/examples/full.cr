class Create
  include Kommando::Command

  def call
  end
end

class UnrelatedCmd
  include Kommando::Command

  def call
  end
end

test do
  root = Kommando::Namespace.root do
    namespace("db") do
      command Create
      command UnrelatedCmd
    end
  end

  assert root.namespaces["db"].commands.keys == ["create", "unrelated_cmd"]
  assert root.namespaces.keys == ["db"]

  root.run(["db", "create"])
end
