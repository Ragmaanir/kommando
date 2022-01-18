require "./spec_helper"

describe Kommando::Parser do
  def parse(*args)
    Kommando::Parser.call(*args)
  end

  test "parse no arguments" do
    assert parse([] of String) == {
      positional: [] of String,
      options:    {} of String => String,
    }
  end

  test "parse options" do
    assert parse(["-name=toby"]) == {
      positional: [] of String,
      options:    {"name" => "toby"},
    }

    assert parse(["-name=toby", "-age=20"]) == {
      positional: [] of String,
      options:    {"name" => "toby", "age" => "20"},
    }
  end

  test "parse options without value" do
    assert parse(["-bool"]) == {
      positional: [] of String,
      options:    {"bool" => nil},
    }

    assert parse(["-name=toby", "-bool"]) == {
      positional: [] of String,
      options:    {"name" => "toby", "bool" => nil},
    }
  end

  test "does not parse negative numbers as options" do
    assert parse(["-100"]) == {
      positional: ["-100"] of String,
      options:    {} of String => String?,
    }

    assert parse(["-name", "-100"]) == {
      positional: ["-100"] of String,
      options:    {"name" => nil},
    }
  end

  test "parse mixed options and arguments" do
    assert parse(["1", "-bool"]) == {
      positional: ["1"] of String,
      options:    {"bool" => nil},
    }

    assert parse(["-name=toby", "test", "-bool"]) == {
      positional: ["test"] of String,
      options:    {"name" => "toby", "bool" => nil},
    }
  end
end
