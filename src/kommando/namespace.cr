module Kommando
  class Namespace(C)
    # alias CommandProc = (Array(String)) ->

    # # alias Commandlike = Command(C).class | CommandProc
    # class Commandlike(C)
    #   getter cmd : Command(C).class | CommandProc

    #   def initialize(@cmd : Command(C).class | CommandProc)
    #   end

    #   def run(ctx : C, args : Array(String))
    #     case cmd
    #     in Command(C).class then cmd.run(ctx, args)
    #     in CommandProc      then cmd.call(ctx, args)
    #     end
    #   end
    # end

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

    def self.root(ctx : C, &block)
      # n = new("root", ctx)
      # with n yield n
      # n
      build("root", ctx) do |n|
        with n yield n
      end
    end

    protected def self.build(name, ctx : C, &block)
      n = new(name, ctx)
      with n yield n
      n
    end

    def initialize(@name, @context : C)
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
      @namespaces[name] = Namespace.build(name, @context) do |n|
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
        # case cmd
        # in Command(C).class then cmd.run(args)
        # in CommandProc      then cmd.call(args)
        # end
        cmd.run(@context, args)
      elsif ns = namespaces[arg]?
        ns.run(args)
      else
        raise "Unrecognized command or namespace: #{arg}"
      end
    end
  end
end
