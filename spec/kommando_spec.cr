require "./spec_helper"

describe Kommando do
  class TestContext
    getter recorded_values = Array(String).new
  end

  class Create < Kommando::Command(TestContext)
    option(:age, Int32, validate: ->(v : Int32) { (13..150).includes?(v) })
    option(:nickname, String, format: /\A[a-zA-Z]+\z/)

    option(:force, Bool, "Description", default: false)

    @[Kommando::Params(name: {format: //})]
    def call(name : String, i : Int32)
      @context.recorded_values << name
      @context.recorded_values << i.to_s
      self
    end
  end

  test "assigns values" do
    ctx = TestContext.new

    cmd = Create.run(ctx, ["-age", "13", "-nickname", "toby", "thename", "55"])

    assert cmd.age == 13
    assert cmd.nickname == "toby"
    assert cmd.force == false

    assert ctx.recorded_values == ["thename", "55"]

    cmd = Create.execute(ctx, "thename", "33", age: 13, nickname: "toby")

    assert cmd.age == 13
    assert cmd.nickname == "toby"
    assert cmd.force == false
  end

  test "executed validations" do
    ctx = TestContext.new

    assert_raises(Kommando::ValidationError) do
      Create.run(ctx, ["-age", "12", "-nickname", "toby"])
    end
  end
end

describe Namespace do
  class Create < Kommando::Command(Nil)
    def call
    end
  end

  class Migrate < Kommando::Command(Nil)
    def call
    end
  end

  test do
    root = Kommando::Namespace.root(nil) do
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
end

describe Examples do
  class Admin < Kommando::Command(Int32)
    def call
    end
  end

  class Build < Kommando::Command(Int32)
    def call
    end
  end

  test do
    app = Kommando::Namespace.root(1337) do
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
