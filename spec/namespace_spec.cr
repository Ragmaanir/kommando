require "./spec_helper"

describe Kommando::Namespace do
  EXECUTION_LOG = [] of String

  class Info
    include Kommando::Command

    def call
      EXECUTION_LOG << self.command_name
    end
  end

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

  def namespace
    Kommando::Namespace.root do
      commands Info

      namespace("db") do
        command Create
        command Migrate
      end
    end
  end

  test "execution" do
    root = namespace

    assert root.commands.keys == ["info"]
    assert root.namespaces.keys == ["db"]

    root.run(["db", "create"])
    root.run(["db", "migrate"])

    assert EXECUTION_LOG == ["create", "migrate"]
  end

  test "root help" do
    root = namespace

    io = IO::Memory.new

    root.run(["help"] of String, io)

    assert io.to_s == <<-STDOUT
    Commands:

      \e[94minfo\e[0m            \e[90mNo description\e[0m

    Namespaces:

      \e[94mdb\e[0m
    \n
    STDOUT
  end

  test "nested namespace help" do
    root = namespace

    io = IO::Memory.new

    root.run(["db", "help"] of String, io)

    assert io.to_s == <<-STDOUT
    Commands:

      \e[94mcreate\e[0m          \e[90mNo description\e[0m
      \e[94mmigrate\e[0m         \e[90mNo description\e[0m
    \n
    STDOUT
  end
end
