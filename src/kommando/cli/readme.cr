require "ecr"
require "../command"

module Kommando
  module Cli
    class Readme < Kommando::Command(Nil)
      class ReadmeTemplate
        ECR.def_to_s "README.md.ecr"
      end

      def call
        puts "Building README.md from README.md.ecr"
        File.write(ROOT / "README.md", ReadmeTemplate.new.to_s)
      end
    end
  end
end
