require "ecr"
require "./version"

module Kommando
  class Cli
    ROOT = Path.new(__DIR__).parent.parent

    class Readme
      ECR.def_to_s "README.md.ecr"
    end

    def self.run(argv = ARGV)
      case argv[0]?
      when "readme"
        puts "Building README.md from README.md.ecr"
        File.write(ROOT / "README.md", Readme.new.to_s)
      else
        puts "Usage: cli readme"
      end
    end

    # def docker(args : Array(String), **options)
    #   cmd("sudo", ["docker", *args], **options)
    # end

    def cmd(name : String, args : Array(String), **options)
      Process.run(
        name,
        args,
        **{output: STDOUT, error: STDERR}.merge(options)
      )
    end
  end
end
