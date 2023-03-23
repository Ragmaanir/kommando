

### TODO

- 🟡 Github CI
- 🟡 exit code: 0 = success, else error code
- 🟡 STDOUT/STDERR distinction
- 🟡 check options/argument names for uniqueness
- 🟡 error on unknown options
- 🟡 simple commands: just a closure with all args + remaining args as param
- 🟣 Types
  - 🟡 enum
  - 🟡 STDIN/File
- 🟣 Validations
  - 🟡 format, greater/less, closure, error messages
  - 🟡 command validation (validate all parameters together)
- 🟣 automatic command documentation
  - 🟡 --help,
  - 🟡 search
  - 🟡 html reference
  - 🟡 interactive documentation
- 🟡 interactive mode: instead of passing parameters, you get a prompt with options
- 🟡 automatic bash auto completion (maybe use interactive mode instead because bash completions suck)
- 🟡 logging
- 🟡 dry-run
- 🟡❓ undo
- 🟡❓ include rake-like features too? e.g. dependencies
- 🟡 error handler, global/per-namespace/per-command
- 🟡 ability to pass parameters as JSON
- 🟡 reusable/embeddable components. e.g. include the same set of commands in multiple places but with different settings.
- 🟡 add features that other tools dont have and that are "new" to the terminal? interactive options?
- 🟡 pre-commit hook to scan project for "XXX" comments

- 🟣 Library:
  - 🟡 building/releasing crystal shards, check that version does not exist yet, check that version is new, git helpers, ...
  - 🟡 progress bar, spinner, notifications, colors, input/confirm, fileutils, file permissions, ...

### DONE

- 🟢 inspectable model: list commands in namespace, list options of command
- 🟢 raise on unexpected extra arguments
- 🟢 raise on short option duplicates
- 🟢 short and long versions
- 🟢 arguments and options
- 🟢 namespaces/subcommands
- 🟢 can be invoked without CLI by calling functions => easy to test
- 🟢 automatically convert parameters and validate them (int, inclusion in list, ...)

- 🏆🔔🚨🛑📌📍📂❗❓🚩💬🧠
- ⭐✅❌❎🔲⛔🚫☑️
- 🔴🟠🟡🟢🔵🟣🟤⚫⚪
- 🔒🔐🔑🛡
- 🛠🔧🐢🪲⚡💥🔥🩸🩹🪦
