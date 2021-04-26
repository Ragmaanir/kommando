require "./spec_helper"

describe Kommando do
  class Create
    include Kommando::Command

    option(:age, Int32, validate: ->(v) { (13..150).includes?(v) })
    option(:nickname, String, format: /\A[a-zA-Z]+\z/)

    option(:force, Bool, "Description", default: false)

    argument(:name, String, format: /\A\w+/)

    def call
      puts "Command called: #{self.inspect}"
    end
  end

  test do
    Create.run(["-age", "12", "-nickname", "toby"])
  end
end
