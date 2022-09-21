require "ecr"
require "../command"

class Kommando::Cli::Readme
  include Kommando::Command

  class ReadmeTemplate
    ECR.def_to_s "README.md.ecr"
  end

  def call
    puts "Building README.md from README.md.ecr"
    File.write(ROOT / "README.md", ReadmeTemplate.new.to_s)
  end
end
