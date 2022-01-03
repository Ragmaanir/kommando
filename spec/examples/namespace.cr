class Create
  include Kommando::Command

  def call
  end
end

class Migrate
  include Kommando::Command

  def call
  end
end

test do
  root = Kommando::Namespace.root do
    commands Create

    namespace("db") do
      commands Create, Migrate
    end
  end

  assert root.commands.keys == ["create"]
  assert root.namespaces.keys == ["db"]

  root.run(["db", "create"])
end
