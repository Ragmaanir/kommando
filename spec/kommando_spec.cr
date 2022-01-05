require "./spec_helper"

describe Kommando do
  COMMANDS = Array(Create).new

  class Create
    include Kommando::Command

    option(:income, Int32, "", default: 0, validate: ->(v : Int32) { v >= 0 && v <= 1_000_000 })
    option(:ssid, String, "", format: /\A[0-9]{10}\z/)
    option(:force, Bool, "Description", default: false)

    arg(:name, String)
    arg(:age, Int32, validate: ->(v : Int32) { (13..150).includes?(v) })

    def call
      COMMANDS << self
    end
  end

  test "assigns values from cmd args" do
    Create.call(["toby", "13", "-ssid=001234"])

    cmd = COMMANDS.last

    assert cmd.is_a?(Create)

    assert cmd.name == "toby"
    assert cmd.age == 13
    assert cmd.ssid == "001234"
    assert cmd.force == false
  end

  test "assign values based on named args" do
    cmd = Create.new("toby", 13, ssid: "001234")

    assert cmd.is_a?(Create)

    assert cmd.name == "toby"
    assert cmd.age == 13
    assert cmd.ssid == "001234"
    assert cmd.force == false
  end

  test "validates argument" do
    assert_raises(Kommando::ValidationError) do
      Create.call(["toby", "-12"])
    end
  end

  test "validates option" do
    assert_raises(Kommando::ValidationError) do
      Create.call(["toby", "13", "-income=-100"])
    end
  end

  test "raises on missing argument" do
    assert_raises(Kommando::MissingArgumentError) do
      Create.call(["toby"])
    end
  end

  test "raises on unexpected arguments" do
    assert_raises(Kommando::UnexpectedArgumentsError) do
      Create.call(["toby", "13", "unexpected"])
    end
  end
end
