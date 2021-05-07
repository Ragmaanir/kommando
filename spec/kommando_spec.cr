require "./spec_helper"

describe Kommando do
  class Create < Kommando::Command
    option(:age, Int32, validate: ->(v : Int32) { (13..150).includes?(v) })
    option(:nickname, String, format: /\A[a-zA-Z]+\z/)

    option(:force, Bool, "Description", default: false)

    @[Kommando::Params(name: {format: //})]
    def call(name : String, i : Int32)
      p name
      p i
      self
    end
  end

  test "assigns values" do
    cmd = Create.run(["-age", "13", "-nickname", "toby", "thename", "55"])

    assert cmd.age == 13
    assert cmd.nickname == "toby"
    assert cmd.force == false

    cmd = Create.execute("thename", "33", age: 13, nickname: "toby")

    assert cmd.age == 13
    assert cmd.nickname == "toby"
    assert cmd.force == false
  end

  test "executed validations" do
    assert_raises(Kommando::ValidationError) do
      Create.run(["-age", "12", "-nickname", "toby"])
    end
  end
end

describe Namespace do
  class Create < Kommando::Command
    def call
    end
  end

  class Migrate < Kommando::Command
    def call
    end
  end

  test do
    root = Kommando::Namespace.root do
      commands Create
      namespace("db") do
        # commands Create, Migrate, Drop, Dump
        commands Create, Migrate
      end
    end

    assert root.commands == {"create" => Create}
    assert root.namespaces.keys == ["db"]

    root.run(["db", "create"])
  end
end

describe Examples do
  class Admin < Kommando::Command
    def call
    end
  end

  class Build < Kommando::Command
    def call
    end
  end

  test do
    app = Kommando::Namespace.root do
      namespace("db") do
        commands Admin # , Console, Create, Migrate, Populate, Start
      end

      namespace("docker") do
        commands Build
      end

      namespace("webapp") do
        # commands Start , Restart
      end
    end
  end
end
