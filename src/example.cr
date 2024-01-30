require "./kommando"

class Example
  include Kommando::Command

  option(:income, Int32, "", default: 0, validate: ->(v : Int32) { v >= 0 && v <= 1_000_000 })
  option(:ssid, String, "", format: /\A[0-9]{10}\z/)
  option(:force, Bool, "Force the change", default: false)

  arg(:name, String)
  arg(:age, Int32, validate: ->(v : Int32) { (13..150).includes?(v) })

  def call
  end
end

cli = Kommando::Namespace.root do
  namespace("examples") do
    command Example
  end
end

cli.exec(ARGV)
