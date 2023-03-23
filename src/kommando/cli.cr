require "./version"
require "../kommando"
require "./cli/readme"
require "./cli/release"

module Kommando
  module Cli
    def self.run(argv = ARGV)
      root = Kommando::Namespace.root do
        command Readme
        command Release
      end

      root.exec(argv)
    end
  end
end

Kommando::Cli.run
