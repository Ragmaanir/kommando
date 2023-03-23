require "./spec_helper"

describe Kommando::Integration do
  def run_db(args : Array(String))
    record_process(args) do
      {{`cat spec/integration/db.cr`}}

      namespace.exec
    end
  end

  test "exec with missing argument" do
    result = run_db(["migrate"])

    assert !result.success?
    assert result.stdout == ""
    assert result.stderr == "Missing argument: 'version' (Int32)\n"
  end

  test "exec with extra argument" do
    result = run_db(["migrate", "42", "extra"])

    assert !result.success?
    assert result.stdout == ""
    assert result.stderr == "Unexpected arguments: extra\n"
  end

  test "exec with malformed argument" do
    result = run_db(["migrate", "xxx"])

    assert !result.success?
    assert result.stdout == ""
    assert result.stderr == %[Validation for 'version' (Int32) failed: "xxx" (Invalid Int32: "xxx")\n]
  end

  test "exec with malformed option" do
    result = run_db(["migrate", "42", "-d=ok"])

    assert !result.success?
    assert result.stdout == ""
    assert result.stderr == <<-OUT
    Validation for 'dry' (Bool) failed: "ok" (Expected one of ["true", "yes", "false", "no"])\n
    OUT
  end

  test "exec with malformed option in long form" do
    result = run_db(["migrate", "42", "-dry=ok"])

    assert !result.success?
    assert result.stdout == ""
    assert result.stderr == <<-OUT
    Validation for 'dry' (Bool) failed: "ok" (Expected one of ["true", "yes", "false", "no"])\n
    OUT
  end

  test "exec with unknwon option" do
    result = run_db(["migrate", "42", "-magic=true"])

    assert !result.success?
    assert result.stdout == ""
    assert result.stderr == "Unknown option: -magic\n"
  end

  test "exec with duplicate option" do
    result = run_db(["migrate", "42", "-d=true", "-dry=false"])

    assert !result.success?
    assert result.stdout == ""
    assert result.stderr == "Duplicate options: -dry, -d\n"
  end
end
