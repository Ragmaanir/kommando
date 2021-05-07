module Kommando
  alias CommandProc = (Array(String)) ->
  alias Commandlike = Command.class | CommandProc

  class Namespace
    getter name : String
    getter namespaces : Hash(String, Namespace) = Hash(String, Namespace).new
    getter commands : Hash(String, Commandlike) = Hash(String, Commandlike).new

    def self.root(&block)
      n = new("root")
      with n yield n
      n
    end

    protected def self.build(name, &block)
      n = new(name)
      with n yield n
      n
    end

    def initialize(@name)
    end

    # def initialize(@name, &block)
    #   with self yield
    # end

    # macro namespace(name, &block)
    #   %n = Namespace.new({{name}})
    #   @namespaces[{{name}}] = %n
    #   with %n yield
    # end

    # XXX
    def namespace(name : String, &block)
      @namespaces[name] = Namespace.build(name) do |n|
        with n yield n
      end
    end

    # def namespace(name : String, &block)
    #   n = Namespace.new(name)
    #   @namespaces[name] = n
    #   with n yield
    # end

    # def namespace(name : String, &block)
    #   @namespaces[name] = Namespace.build(name) do
    #     with self yield
    #   end
    # end

    def commands(*cmds : Command.class)
      cmds.each do |cmd|
        @commands[cmd.command_name] = cmd
      end
    end

    def run(args : Array(String))
      args = args.dup
      arg = args.shift

      if cmd = commands[arg]?
        case cmd
        in Command.class then cmd.run(args)
        in CommandProc   then cmd.call(args)
        end
      elsif ns = namespaces[arg]?
        ns.run(args)
      else
        raise "Unrecognized command or namespace: #{arg}"
      end
    end
  end
end
