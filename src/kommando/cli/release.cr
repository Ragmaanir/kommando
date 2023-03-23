require "../command"

class Kommando::Cli::Release
  include Kommando::Command

  arg :version, String

  def call
    # TODO: implement
    puts "TODO: release version #{version}"
  end
end
