require "./spec_helper"

describe Kommando do
  COMMANDS = Array(Create).new

  class Create
    include Kommando::Command

    option(:age, Int32, "", validate: ->(v : Int32) { (13..150).includes?(v) })
    option(:nickname, String, "", format: /\A[a-zA-Z]+\z/)

    option(:force, Bool, "Description", default: false)

    arg(:name, String)

    def call
      COMMANDS << self
    end
  end

  test "assigns values from cmd args" do
    Create.call(["thename", "55", "-age", "13", "-nickname", "toby"])

    cmd = COMMANDS.last

    assert cmd.is_a?(Create)

    assert cmd.age == 13
    assert cmd.nickname == "toby"
    assert cmd.force == false
  end

  test "assign values based on named args" do
    cmd = Create.new("thename", "33", age: 13, nickname: "toby")

    assert cmd.is_a?(Create)

    assert cmd.age == 13
    assert cmd.nickname == "toby"
    assert cmd.force == false
  end

  test "executed validations" do
    assert_raises(Kommando::MissingArgumentError) do
      Create.call(["-age", "12", "-nickname", "toby"])
    end
  end
end
