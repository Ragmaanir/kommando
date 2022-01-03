require "./spec_helper"

describe Kommando::Namespace do
  EXECUTION_LOG = [] of String

  class Create
    include Kommando::Command

    def call
      EXECUTION_LOG << self.command_name
    end
  end

  class Migrate
    include Kommando::Command

    def call
      EXECUTION_LOG << self.command_name
    end
  end

  test do
    root = Kommando::Namespace.root do
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

    assert EXECUTION_LOG == ["create", "migrate"]
  end
end
