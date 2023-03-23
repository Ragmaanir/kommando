require "microtest"

require "../src/kommando"

# class TestContext
#   getter called = Hash(String, Kommando::Command(self)).new

#   def record(cmd : Kommando::Command(self))
#     @called[cmd.class.name] = cmd
#   end
# end

# # https://forum.crystal-lang.org/t/using-spec-module-is-it-possible-to-store-what-is-printed/5448/4
# def capture_out(&)
#   original_stdout = File.open("/dev/null")
#   original_stdout.reopen(STDOUT)

#   original_stderr = File.open("/dev/null")
#   original_stderr.reopen(STDERR)

#   begin
#     stdout_reader, stdout_writer = IO.pipe
#     stderr_reader, stderr_writer = IO.pipe
#     STDERR.reopen(stderr_writer)
#     STDOUT.reopen(stdout_writer)

#     result = yield

#     user_stdout = stdout_reader.gets_to_end
#     user_stderr = stderr_reader.gets_to_end

#     {result, user_stdout, user_stderr}
#   rescue e : Exception
#     error_string = String.build do |str|
#       str << user_stderr
#       e.inspect_with_backtrace(str)
#     end

#     {nil, user_stdout, error_string}
#   ensure
#     [
#       stdout_reader, stdout_writer, stderr_reader,
#       stderr_writer, original_stdout, original_stderr,
#     ].each(&.try(&.close))

#     STDOUT.reopen(original_stdout)
#     STDERR.reopen(original_stderr)
#   end
# end

class StdoutResult
  getter status : Process::Status
  getter stdout : String
  getter stderr : String

  def initialize(@status, @stdout, @stderr)
  end

  def success?
    status.success?
  end

  def to_s(io : IO)
    if success?
      io << stdout
    else
      io << stderr
      io << stdout
    end
  end
end

macro record_process(args, &block)
  {%
    c = <<-CRYSTAL
      require "../src/kommando"
      #{block.body.id}
    CRYSTAL
  %}

  input = IO::Memory.new({{c}})
  stdout = IO::Memory.new
  stderr = IO::Memory.new

  s = Process.run(
    "crystal", [
      "run", "--error-trace", "--stdin-filename", "#{__DIR__}/test.cr",
      "--", *{{args}}
    ],
    input: input, output: stdout, error: stderr
  )

  StdoutResult.new(s, stdout.to_s, stderr.to_s)
end

# macro compile_integration(name, &block)
#   {%
#     c = <<-CRYSTAL
#       require "../src/kommando"
#       #{block.body.id}
#     CRYSTAL
#   %}

#   input = IO::Memory.new({{c}})
#   stdout = IO::Memory.new
#   stderr = IO::Memory.new

#   s = Process.run(
#     "crystal",
#     ["build",
#       "--error-trace",
#       "--stdin-filename", "#{__DIR__}/test.cr",
#       "-o", {{name.stringify}}
#     ],
#     input: input, output: stdout, error: stderr
#   )

#   raise "Compile failed for #{name}: #{stderr}" if !s.success?

#   s
# end

# def run_integration(name : String, args : Array(String))
#   stdout = IO::Memory.new
#   stderr = IO::Memory.new

#   s = Process.run(name, args, output: stdout, error: stderr)

#   StdoutResult.new(s, stdout.to_s, stderr.to_s)
# end

include Microtest::DSL
Microtest.run!
