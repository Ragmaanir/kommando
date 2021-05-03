require "./spec_helper"

describe Kommando do
  class Create < Kommando::Command
    option(:age, Int32, validate: ->(v : Int32) { (13..150).includes?(v) })
    option(:nickname, String, format: /\A[a-zA-Z]+\z/)

    option(:force, Bool, "Description", default: false)

    argument(:name, String, format: /\A\w+/)

    def call
      puts "Command called: #{self.inspect}"
    end
  end

  test "executed validations" do
    Create.run(["-age", "13", "-nickname", "toby"])

    assert_raises(Kommando::ValidationError) do
      Create.run(["-age", "12", "-nickname", "toby"])
    end
  end
end

describe Kommando::Namespace do
  class Create < Kommando::Command
    def call
      puts "Command called: #{self.inspect}"
    end
  end

  class Migrate < Kommando::Command
    def call
      puts "Command called: #{self.inspect}"
    end
  end

  test do
    root = Kommando::Namespace.build("root") do
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
