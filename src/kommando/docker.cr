module Kommando
  module Docker
    # def self.images(str : String)
    #   lines = str.split("\n")

    #   lines.map { |l| /\ASuccessfully built ([a-z0-9]+)/.match(l) }.compact.map(&.[1])
    # end

    def self.build(args : Array(String), cache : Bool = true, **options)
      args = ["--no-cache"] + args if !cache
      execute(["build", *args], **options)
    end

    def self.run(args : Array(String), **options)
      execute(["run", *args], **options)
    end

    private def self.execute(args : Array(String), **options)
      options = {output: STDOUT, error: STDERR}.merge(options)

      # stdio = IO::Memory.new
      # stderr = IO::Memory.new

      status = Process.run(
        "sudo",
        ["docker", *args],
        **options
      )

      # if status.success?
      #   print "✓ ".colorize(:green)

      #   # puts "#{name} [#{Docker.images(stdio.to_s).last}]"
      #   # puts stdio.to_s.split("\n")[-3]
      # else
      #   print "× ".colorize(:red)
      #   puts "#{name}"

      #   puts stdio.to_s
      #   puts stderr.to_s
      # end

      raise "Error running: sudo docker #{args}" if !status.success?
    end
  end
end
