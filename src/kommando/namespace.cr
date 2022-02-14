module Kommando
  class Namespace
    # https://github.com/crystal-lang/crystal/issues/2803
    # alias CommandProc = (Array(String)) ->

    getter name : String
    getter namespaces : Hash(String, Namespace) = Hash(String, Namespace).new
    getter commands : Hash(String, (Array(String) ->)) = Hash(String, (Array(String) ->)).new

    def self.root(&)
      build("root") do |n|
        with n yield n
      end
    end

    protected def self.build(name, &)
      n = new(name)
      with n yield n
      n
    end

    def initialize(@name)
    end

    def namespace(name : String | Symbol, &)
      @namespaces[name.to_s] = Namespace.build(name.to_s) do |n|
        with n yield n
      end
    end

    def commands(*cmds : Command.class)
      cmds.each do |cmd|
        command(cmd)
      end
    end

    def command(cmd : Command.class, name : String = cmd.command_name)
      @commands[name] = ->(args : Array(String)) {
        cmd.call(args)
      }
    end

    def run(args : Array(String))
      args = args.dup
      arg = args.shift

      if cmd = commands[arg]?
        cmd.call(args)
      elsif ns = namespaces[arg]?
        ns.run(args)
      else
        raise "Unrecognized command or namespace: #{arg}"
      end
    end
  end
end
