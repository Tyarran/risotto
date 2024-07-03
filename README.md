# Risotto

Risotto is an Elixir library for creating test data factories.

## Features

- **Simple and Clean Syntax:** Risotto provides an intuitive syntax for defining factories, making it easy to generate test data.
- **Flexible Data Generation:** Generate complex data structures with ease using Risotto's built-in support for associations and sequences.
- **Integration with ExUnit:** Seamlessly integrate Risotto with ExUnit to streamline your testing workflow.
- **Customizable:** Customize factory definitions to suit your specific testing needs.

## Installation

To use Risotto in your Elixir project, add it as a dependency in your `mix.exs` file:

```elixir
def deps do
  [
    {:risotto, "~> 0.1.0"}
  ]
end
```

Then, run:

```bash
$ mix deps.get
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and published on [HexDocs](https://hexdocs.pm). Once published, the docs can be found at <https://hexdocs.pm/risotto>.

## Usage

### Defining Factories

Define your factories using the `Risotto` module. Here's an example of how you can define a factory for generating user data:

```elixir
defmodule MyApp.UserFactory do
  use Risotto

  factory User do
    field(:first_name, "John")
    field(:last_name, "Doe")
    field(:age, 42)
    field(:address, subfactory(MyApp.AddressFactory))
  end
end
```

### Using Factories in Tests

You can use the defined factories in your tests to create test data. Here's an example of how you can use the `build!/1` function to create a user struct:

```elixir
defmodule MyApp.UserTest do
  use ExUnit.Case

  test "creates a user" do
    user = UserFactory.build!()

    assert user.first_name == "John"
    assert user.last_name == "Doe"
    assert user.age == 42
    assert user.address == %MyApp.Address{}
  end
end
```

You can also pass field values to customize the data building depending on your tests:

```elixir
defmodule MyApp.UserTest do
  use ExUnit.Case

  test "creates a user" do
    user = UserFactory.build!(first_name: "Romain", last_name: "Commandé", age: 37, address: %MyApp.Address{city: "Paris"})

    assert user.first_name == "Romain"
    assert user.last_name == "Commandé"
    assert user.age == 37
    assert user.address == %MyApp.Address{city: "Paris"}
  end
end
```

For more information on how to use Risotto, please refer to the [documentation](https://risotto-docs.example.com).

## Contributing

Contributions to Risotto are welcome! If you'd like to contribute, please fork the repository, create a new branch, commit your changes, and open a pull request.

## License

Risotto is released under the MIT License. See [LICENSE](LICENSE) for details.
