defmodule RisottoTest do
  use ExUnit.Case

  defmodule Person do
    @enforce_keys [:first_name, :last_name, :age]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            first_name: String.t(),
            last_name: String.t(),
            age: non_neg_integer()
          }
  end

  defmodule PersonFactory do
    @moduledoc """
    A simple factory for the `Person` struct.
    """
    use Risotto

    factory Person do
      field(:first_name, "John")
      field(:last_name, "Doe")
      field(:age, 42)
    end
  end

  defmodule PersonFactory2 do
    @moduledoc """
    A factory for the `Person` struct with a function as a default value.
    """
    use Risotto

    factory Person do
      field(:first_name, "John")
      field(:last_name, "Doe")
      field(:age, fn -> 42 end)
    end
  end

  describe "PersonFactory" do
    test "builds a person" do
      result = PersonFactory.build()

      assert result.first_name == "John"
      assert result.last_name == "Doe"
      assert result.age == 42
    end

    test "builds a person with params" do
      age = Date.utc_today().year - 1986

      result = PersonFactory.build(first_name: "Romain", last_name: "Commandé", age: age)

      assert result.first_name == "Romain"
      assert result.last_name == "Commandé"
      assert result.age == age
    end
  end

  describe "PersonFactory2" do
    test "builds a person" do
      result = PersonFactory2.build()

      assert result.first_name == "John"
      assert result.last_name == "Doe"
      assert result.age == 42
    end

    test "builds a person with params" do
      age = Date.utc_today().year - 1986

      result = PersonFactory2.build(first_name: "Romain", last_name: "Commandé", age: age)

      assert result.first_name == "Romain"
      assert result.last_name == "Commandé"
      assert result.age == age
    end
  end
end
