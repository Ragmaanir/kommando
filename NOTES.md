
### Inspiration

 - https://nullprogram.com/blog/2020/08/01/
 - http://docopt.org/
 - https://eng.localytics.com/exploring-cli-best-practices/
 - thor, rake
 - https://github.com/dazuma/toys

### Validation

Provided validations:

- String: format/inclusion
- Int32: min/max/range/inclusion
- Path: existence/permissions/subpath_of

Patterns

Bool: -b; -b=true; --bool; --bool=true
String: -s=word; -s='multiple words'; --string=word

Use cases:

- crystal run src/start.cr --error-trace
- docker run -it myimage /bin/bash

