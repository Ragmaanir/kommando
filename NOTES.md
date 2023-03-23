
### Inspiration

 - https://nullprogram.com/blog/2020/08/01/
 - http://docopt.org/
 - https://eng.localytics.com/exploring-cli-best-practices/
 - thor, rake
 - https://github.com/dazuma/toys

### Features

- [ ] Interactive mode so one does not have to call `-h` all the time
- [ ] Validation and parsing
  - Should validation happen before or after parsing? Probably after. Validation before is done by the parser itself.
  - What about contextual validation? E.g. option_a > option_b
  - Show better validation errors
- [ ] Git allows options for parent and subcommands simultaneously:
  `program -a -b -c subcommand -x -y -z`
  This would require some kind of namespace-options which would be accessible for all commands in that namespace.

### Validation

Provided validations:

- String: format/inclusion
- Int32: min/max/range/inclusion
- Path: existence/permissions/subpath_of

Patterns

Bool: -b; -b=true; -bool; -bool=true
String: -s=word; -s='multiple words'; -string=word

Use cases:

- crystal run src/start.cr --error-trace
- docker run -it myimage /bin/bash

### Implementations

- Instances: Namespaces are instances containing other namespaces and command-like objects
