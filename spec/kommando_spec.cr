require "./spec_helper"

describe Kommando do
  class Ctx
    property cmd : Kommando::Command(self)?
  end

  class Create < Kommando::Command(Ctx)
    option(:age, Int32, validate: ->(v : Int32) { (13..150).includes?(v) })
    option(:nickname, String, format: /\A[a-zA-Z]+\z/)

    option(:force, Bool, "Description", default: false)

    @[Kommando::Params(name: {format: //})]
    def call(name : String, i : Int32)
      @context.cmd = self
    end
  end

  test "assigns values from cmd args" do
    ctx = Ctx.new

    Create.run(ctx, ["-age", "13", "-nickname", "toby", "thename", "55"])

    cmd = ctx.cmd.not_nil!

    assert cmd.is_a?(Create)

    assert cmd.age == 13
    assert cmd.nickname == "toby"
    assert cmd.force == false
  end

  test "assign values based on named args" do
    ctx = Ctx.new

    Create.execute(ctx, "thename", "33", age: 13, nickname: "toby")

    cmd = ctx.cmd.not_nil!

    assert cmd.is_a?(Create)

    assert cmd.age == 13
    assert cmd.nickname == "toby"
    assert cmd.force == false
  end

  test "executed validations" do
    ctx = Ctx.new

    assert_raises(Kommando::ValidationError) do
      Create.run(ctx, ["-age", "12", "-nickname", "toby"])
    end
  end
end
