require "./spec_helper"

describe Kommando::Namespace do
  EXECUTION_LOG = [] of String

  class Info
    include Kommando::Command

    def self.description
      "Prints information"
    end

    arg :version, Int32

    option :dry, Bool, "Simulate migration", default: false
    option :verbose, Bool, "More detailed output", default: false

    def call
      EXECUTION_LOG << self.command_name
    end
  end

  class Create
    include Kommando::Command

    def self.description
      "Create the database"
    end

    def call
      EXECUTION_LOG << self.command_name
    end
  end

  class Migrate
    include Kommando::Command

    def self.description
      "Run pending migrations"
    end

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

    root.run(["help"], io)

    assert io.to_s == <<-STDOUT
    Commands:

    \e[94m  info            \e[0m\e[90mPrints information\e[0m

    Namespaces:

      \e[94mdb\e[0m
    \n
    STDOUT
  end

  test "nested namespace help" do
    root = namespace

    io = IO::Memory.new

    root.run(["db", "help"], io)

    assert io.to_s == <<-STDOUT
    Commands:

    \e[94m  create          \e[0m\e[90mCreate the database\e[0m
    \e[94m  migrate         \e[0m\e[90mRun pending migrations\e[0m
    \n
    STDOUT
  end

  test "command help" do
    root = namespace

    io = IO::Memory.new

    root.run(["help", "info"], io)

    assert io.to_s == <<-STDOUT
    \e[33minfo\e[0m: \e[90mPrints information\e[0m

    Usage: \e[33minfo\e[0m \e[94mversion\e[0m \e[90m-option=value\e[0m

    Positional:
    \e[94m  version   \e[0m : \e[35mInt32   \e[0m

    Options:
    \e[94m  dry        \e[0m\e[36m-d\e[0m : \e[35mBool    \e[0m \e[90mSimulate migration\e[0m
    \e[94m  verbose    \e[0m\e[36m-v\e[0m : \e[35mBool    \e[0m \e[90mMore detailed output\e[0m
    \n
    STDOUT
  end
end
