# Kommando [![Crystal CI](https://github.com/Ragmaanir/kommando/actions/workflows/crystal.yml/badge.svg)](https://github.com/Ragmaanir/kommando/actions/workflows/crystal.yml)

### Version 0.1.2

Kommando is a library that helps you build small and large command line interfaces in crystal.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  kommando:
    github: ragmaanir/kommando
```

## Features

- positional arguments (like in `crystal init app MyApp`)
- short and long options (like `cli new MyProject --dry -v --permissions=644 --repo=github -l=MIT`)
- validation and type conversion of arguments
- auto-generated documentation
- namespaces/subcommands like `cli create user Toby`

## Rationale

**Why classes for commands and not methods**

Classes can define helper methods that are scoped to the command. And the helper methods have access to all options of the command.


## Usage

### Commands

```crystal
record(User, name : String, age : Int32, height : Int32?, nickname : String?)

USERS = [] of User

class Create
  include Kommando::Command
  option(:height, Int32, "", validate: ->(v : Int32) { (100..250).includes?(v) })
  option(:nickname, String, "", format: /\A[a-zA-Z]+\z/)

  option(:dead, Bool, "Whether the person is dead", default: false)

  arg(:name, String)
  arg(:age, Int32)

  def call
    USERS << User.new(name, age, @height, @nickname)
  end
end

test "create user with options" do
  user = User.new("Christian", 55, 175, "Chris")

  Create.call([
    "-height=#{user.height}",
    "-nickname=#{user.nickname}",
    user.name, user.age.to_s,
  ])

  assert USERS == [user]
end

```

### Namespaces

```crystal
require "kommando"

class Create
  include Kommando::Command

  def call
  end
end

class Migrate
  include Kommando::Command

  def call
  end
end

test do
  root = Kommando::Namespace.root do
    commands Create

    namespace("db") do
      commands Create, Migrate
    end
  end

  assert root.commands.keys == ["create"]
  assert root.namespaces.keys == ["db"]

  root.run(["db", "create"])
end

```

## Contributing

1. Fork it (https://github.com/ragmaanir/kommando/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [ragmaanir](https://github.com/ragmaanir) ragmaanir - creator, maintainer
