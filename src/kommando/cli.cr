require "./version"
require "../kommando"
require "./cli/readme"

module Kommando
  module Cli
    ROOT = Path.new(__DIR__).parent.parent

    def self.run(argv = ARGV)
      root = Kommando::Namespace.root(nil) do
        command Readme
      end

      root.run(argv)
    end

    def cmd(name : String, args : Array(String), **options)
      Process.run(
        name,
        args,
        **{output: STDOUT, error: STDERR}.merge(options)
      )
    end
  end
end
