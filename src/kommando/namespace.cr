require "colorize"

module Kommando
  class Namespace
    HELP           = %w{help ?}
    RESERVED_NAMES = HELP

    getter name : String
    getter namespaces = Hash(String, Namespace).new
    getter commands = Hash(String, Command::Meta).new

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
      raise "The name #{name.inspect} is reserved" if name.in?(RESERVED_NAMES)
      raise "A namespace with the name #{name.inspect} already exists" if @namespaces[name]?

      @namespaces[name.to_s] = Namespace.build(name.to_s) do |n|
        with n yield n
      end
    end

    def commands(*cmds : Command::Meta)
      cmds.each do |cmd|
        command(cmd)
      end
    end

    def command(cmd : Command::Meta, name : String = cmd.command_name)
      raise "The name #{name.inspect} is reserved" if name.in?(RESERVED_NAMES)
      raise "A command with the name #{name.inspect} already exists" if @commands[name]?

      @commands[name] = cmd
    end

    # Like `#run`, but prints execptions to stderr and exits the Process.
    # This method makes the namespace act as a CLI.
    def exec(args : Array(String) = ARGV, io : IO = STDOUT, err : IO = STDERR)
      run(args, io)
    rescue e : ValidationError | MissingArgumentError | UnexpectedArgumentsError | DuplicateOptionError | UnknownOptionError
      err.puts e.message
      exit 1
    end

    def run(args : Array(String), io : IO = STDOUT)
      args = args.dup
      arg = args.shift?

      if arg == nil || arg.in?(HELP)
        help(args, io)
      elsif cmd = @commands[arg]?
        cmd.call(args)
      elsif ns = @namespaces[arg]?
        ns.run(args, io)
      else
        io.puts "Unrecognized command or namespace: #{arg.inspect}".colorize(RED)
        io.puts
        help([] of String, io)
        exit 1
      end
    end

    def help(args : Array(String), io : IO)
      if args.empty?
        if !@commands.empty?
          io.puts "Commands:"
          io.puts

          @commands.each do |name, cmd|
            io << ("  %-16s" % name).colorize(LIGHT_BLUE)

            io << cmd.description.colorize(DARK_GRAY)

            io.puts
          end

          io.puts
        end

        if !@namespaces.empty?
          io.puts "Namespaces:"
          io.puts

          @namespaces.each do |name, _ns|
            io << "  "
            io << name.colorize(LIGHT_BLUE)
            io.puts
          end

          io.puts
        end
      else
        if cmd = @commands[args.first]?
          cmd.describe(io)
        else
          raise "No command #{args.first.inspect} found in namespace #{name}"
        end
      end
    end
  end
end
