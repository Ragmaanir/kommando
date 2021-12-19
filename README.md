# Kommando [![Crystal CI](https://github.com/Ragmaanir/kommando/actions/workflows/crystal.yml/badge.svg)](https://github.com/Ragmaanir/kommando/actions/workflows/crystal.yml)

### Version 0.1.0

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

**Why are positional arguments specified as method parameters and options using the `options`-macro?**

Usually commands have many options and just a few arguments. It is easier to spread the options out using the `option`-macro than having them in the method signature or in one big annotation. Specifying a description, validations etc for each options is easier that way too.


## Usage

### Commands

```crystal
record(User, name : String, age : Int32, height : Int32?, nickname : String?)

USERS = [] of User

class Create < Kommando::Command(Nil)
  option(:height, Int32, validate: ->(v : Int32) { (100..250).includes?(v) })
  option(:nickname, String, format: /\A[a-zA-Z]+\z/)

  option(:dead, Bool, "Wether the person is dead", default: false)

  def call(name : String, age : Int32)
    USERS << User.new(name, age, @height, @nickname)
  end
end

test "create user with options" do
  user = User.new("Christian", 55, 175, "Chris")

  Create.run(nil, [
    "-height", user.height.to_s,
    "-nickname", user.nickname.to_s,
    user.name, user.age.to_s,
  ])

  assert USERS == [user]
end

```

### Namespaces

```crystal
require "kommando"

class Create < Kommando::Command(Nil)
  def call
  end
end

class Migrate < Kommando::Command(Nil)
  def call
  end
end

test do
  ctx = nil

  root = Kommando::Namespace.root(ctx) do
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

```crystal
require "kommando"

class Ctx
end

class Create < Kommando::Command(Ctx)
  def call
  end
end

class UnrelatedCmd < Kommando::Command(Nil)
  def call
  end
end

test do
  ctx = Ctx.new

  root = Kommando::Namespace.root(ctx) do
    namespace("db") do
      command Create
      command UnrelatedCmd
    end
  end

  assert root.namespaces["db"].commands.keys == ["create", "unrelated_cmd"]
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
