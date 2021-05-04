
### Requirements

 - https://nullprogram.com/blog/2020/08/01/
 - http://docopt.org/
 - subcommands
 - short and long versions
 - check options short and long names for uniqueness
 - simple commands: just a closure with all args + remaining args as param
 - automatic convert parameters and validate them (int, inclusion in list, ...)
 - command validation (validate all parameters together)
 - automatic documentation (man, --help, html reference)
 - inspectable model
 - reusable/embeddable components. e.g. include the same set of
   commands in multiple places but with different settings.
 - automatic bash auto completion
 - can be invoked without CLI by calling functions => easy to test
 - use helper methods in each command
 - library for: progress bar, spinner, notifications, colors, input/confirm, fileutils, file permissions, ...

Patterns

Bool: -b; -b=true; --bool; --bool=true
String: -s=word; -s='multiple words'; --string=word

