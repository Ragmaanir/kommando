module Kommando
  class Namespace(C)
    # https://github.com/crystal-lang/crystal/issues/2803
    # alias CommandProc = (Array(String)) ->
    # alias Commandlike = Command(C).class | CommandProc

    class Commandlike(C)
      getter cmd : (C, Array(String)) ->

      def initialize(@cmd)
      end

      def run(ctx : C, args : Array(String))
        cmd.call(ctx, args)
      end
    end

    getter name : String
    getter namespaces : Hash(String, Namespace(C)) = Hash(String, Namespace(C)).new
    getter commands : Hash(String, Commandlike(C)) = Hash(String, Commandlike(C)).new

    @context : C

    def self.root(ctx : C, &)
      build("root", ctx) do |n|
        with n yield n
      end
    end

    protected def self.build(name, ctx : C, &)
      n = new(name, ctx)
      with n yield n
      n
    end

    def initialize(@name, @context : C)
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
      @namespaces[name] = Namespace.build(name, @context) do |n|
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

    def commands(*cmds : Command(C).class)
      cmds.each do |cmd|
        @commands[cmd.command_name] = Commandlike(C).new(
          ->(ctx : C, args : Array(String)) {
            cmd.run(ctx, args)
          }
        )
      end
    end

    def run(args : Array(String))
      args = args.dup
      arg = args.shift

      if cmd = commands[arg]?
        cmd.run(@context, args)
      elsif ns = namespaces[arg]?
        ns.run(args)
      else
        raise "Unrecognized command or namespace: #{arg}"
      end
    end
  end
end
