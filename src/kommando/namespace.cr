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

    def run(args : Array(String), io : IO = STDOUT)
      args = args.dup
      arg = args.shift

      if cmd = @commands[arg]?
        cmd.call(args)
      elsif ns = @namespaces[arg]?
        ns.run(args, io)
      elsif arg.in?(HELP)
        help(args, io)
      else
        raise "Unrecognized command or namespace: #{arg.inspect}"
      end
    end

    def help(args : Array(String), io : IO)
      indent = " "*2

      if args.empty?
        if !@commands.empty?
          io.puts "Commands:"
          io.puts

          @commands.each do |name, cmd|
            io << indent
            io << ("%-16s" % name).colorize(:light_blue)

            io << cmd.description.colorize(:dark_gray)

            io.puts
          end

          io.puts
        end

        if !@namespaces.empty?
          io.puts "Namespaces:"
          io.puts

          @namespaces.each do |name, _ns|
            io << indent
            io << name.colorize(:light_blue)
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
