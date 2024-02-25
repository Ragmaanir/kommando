module Kommando::Helpers
  def run!(*args : String | Path, **options)
    r = Process.run(
      args.first.to_s, args.skip(1).map(&.to_s),
      output: STDOUT,
      error: STDOUT
    )

    raise "Command failed" if !r.success?

    r
  end
end
