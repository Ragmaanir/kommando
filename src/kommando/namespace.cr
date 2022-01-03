module Kommando
  class Namespace
    # https://github.com/crystal-lang/crystal/issues/2803
    # alias CommandProc = (Array(String)) ->
    # alias Commandlike = Command(C).class | CommandProc
    class Commandlike
      getter cmd : Array(String) ->

      def initialize(@cmd)
      end

      def run(args : Array(String))
        cmd.call(args)
      end
    end

    getter name : String
    getter namespaces : Hash(String, Namespace) = Hash(String, Namespace).new
    getter commands : Hash(String, Commandlike) = Hash(String, Commandlike).new

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

    # def initialize(@name, &)
    #   with self yield
    # end

    # macro namespace(name, &)
    #   %n = Namespace.new({{name}})
    #   @namespaces[{{name}}] = %n
    #   with %n yield
    # end

    # XXX
    def namespace(name : String, &)
      @namespaces[name] = Namespace.build(name) do |n|
        with n yield n
      end
    end

    # def namespace(name : String, &)
    #   n = Namespace.new(name)
    #   @namespaces[name] = n
    #   with n yield
    # end

    # def namespace(name : String, &)
    #   @namespaces[name] = Namespace.build(name) do
    #     with self yield
    #   end
    # end

    def commands(*cmds : Command.class)
      cmds.each do |cmd|
        command(cmd)
      end
    end

    def command(cmd : Command.class)
      @commands[cmd.command_name] = Commandlike.new(
        ->(args : Array(String)) {
          cmd.call(args)
        }
      )
    end

    def run(args : Array(String))
      args = args.dup
      arg = args.shift

      if cmd = commands[arg]?
        cmd.run(args)
      elsif ns = namespaces[arg]?
        ns.run(args)
      else
        raise "Unrecognized command or namespace: #{arg}"
      end
    end
  end
end
