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

  def run_and_capture(args : Array(String))
    root = namespace
    io = IO::Memory.new

    c = Colorize.enabled?
    Colorize.enabled = true
    root.run(args, io)
    Colorize.enabled = c

    io.to_s
  end

  test "run" do
    root = namespace

    assert root.commands.keys == ["info"]
    assert root.namespaces.keys == ["db"]

    root.run(["db", "create"])
    root.run(["db", "migrate"])

    assert EXECUTION_LOG == ["create", "migrate"]
  end

  test "validation failures" do
    assert_raises(MissingArgumentError) { run_and_capture(["info"]) }
    assert_raises(UnexpectedArgumentsError) { run_and_capture(["info", "123", "456", "789"]) }
    assert_raises(ValidationError) { run_and_capture(["info", "xxx"]) }
    assert_raises(ValidationError) { run_and_capture(["info", "123", "-d=xxx"]) }
    assert_raises(DuplicateOptionError) { run_and_capture(["info", "123", "-d=yes", "-dry"]) }
  end

  test "root help" do
    assert run_and_capture(["help"]) == <<-STDOUT
    Commands:

    \e[38;2;90;90;250m  info            \e[0m\e[38;2;100;100;100mPrints information\e[0m

    Namespaces:

      \e[38;2;90;90;250mdb\e[0m
    \n
    STDOUT
  end

  test "nested namespace help" do
    assert run_and_capture(["db", "help"]) == <<-STDOUT
    Commands:

    \e[38;2;90;90;250m  create          \e[0m\e[38;2;100;100;100mCreate the database\e[0m
    \e[38;2;90;90;250m  migrate         \e[0m\e[38;2;100;100;100mRun pending migrations\e[0m
    \n
    STDOUT
  end

  test "command help" do
    assert run_and_capture(["help", "info"]) == <<-STDOUT
    \e[38;2;220;220;0minfo\e[0m: \e[38;2;100;100;100mPrints information\e[0m

    Usage: \e[38;2;220;220;0minfo\e[0m \e[38;2;90;90;250mversion\e[0m \e[38;2;100;100;100m-option=value\e[0m

    Positional:
    \e[38;2;90;90;250m  version   \e[0m : \e[38;2;205;0;205mInt32   \e[0m

    Options:
    \e[38;2;90;90;250m  dry        \e[0m\e[38;2;0;205;205m-d\e[0m : \e[38;2;205;0;205mBool    \e[0m \e[38;2;100;100;100mSimulate migration\e[0m
    \e[38;2;90;90;250m  verbose    \e[0m\e[38;2;0;205;205m-v\e[0m : \e[38;2;205;0;205mBool    \e[0m \e[38;2;100;100;100mMore detailed output\e[0m
    \n
    STDOUT
  end
end
