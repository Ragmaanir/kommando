

### TODO

- Github CI
- exit code: 0 = success, else error code
- STDOUT/STDERR distinction
- namespaces/subcommands
- short and long versions
- check options short and long names for uniqueness
- simple commands: just a closure with all args + remaining args as param
- automatically convert parameters and validate them (int, inclusion in list, ...)
- command validation (validate all parameters together)
- reusable/embeddable components. e.g. include the same set of commands in multiple places but with different settings.
- can be invoked without CLI by calling functions => easy to test
- error handler, global/per-namespace/per-command
- automatic documentation (man, --help, interactive help, search, html reference)
- automatic bash auto completion
- logfile
- dry-run
- undo
- include rake-like features too? e.g. dependencies
- interactive mode: instead of passing parameters, you get a prompt with options
- interactive documentation
- option to pass parameters as JSON

- Library:
  - building/releasing crystal shards, check that version does not exist yet, check that version is new, git helpers, ...
  - progress bar, spinner, notifications, colors, input/confirm, fileutils, file permissions, ...
- add features that other tools dont have and that are "new" to the terminal? interactive options?
- inspectable model: list commands in namespace, list options of command

- pre-commit hook to scan project for "XXX" comments

### DONE
