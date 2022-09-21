require "./version"
require "../kommando"
require "./cli/readme"

module Kommando
  module Cli
    def self.run(argv = ARGV)
      root = Kommando::Namespace.root do
        command Readme
      end

      root.run(argv)
    end
  end
end

Kommando::Cli.run
