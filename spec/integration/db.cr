class Migrate
  include Kommando::Command

  def self.description
    "Migrate the db"
  end

  arg :version, Int32

  option :dry, Bool, "Simulate migration", default: false
  option :verbose, Bool, "More detailed output", default: false

  def call
    puts "Executed"
  end
end

def namespace
  Kommando::Namespace.root do
    commands Migrate
  end
end
