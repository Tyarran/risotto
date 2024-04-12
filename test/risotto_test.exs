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

  defmodule PersonFactory3 do
    @moduledoc """
    A factory for the `Person` struch wich throw an exception with the age field 
    """
    use Risotto

    factory Person do
      field(:first_name, "John")
      field(:last_name, "Doe")
      # Will throw an exception
      field(:age, fn -> raise "boom!" end)
    end
  end

  describe "PersonFactory" do
    test "builds a person" do
      person = PersonFactory.build!()

      assert person.first_name == "John"
      assert person.last_name == "Doe"
      assert person.age == 42
    end

    test "builds a person with params" do
      age = Date.utc_today().year - 1986

      person = PersonFactory.build!(first_name: "Romain", last_name: "Commandé", age: age)

      assert person.first_name == "Romain"
      assert person.last_name == "Commandé"
      assert person.age == age
    end
  end

  describe "PersonFactory2" do
    test "builds a person" do
      person = PersonFactory2.build!()

      assert person.first_name == "John"
      assert person.last_name == "Doe"
      assert person.age == 42
    end

    test "builds a person with params" do
      age = Date.utc_today().year - 1986

      person = PersonFactory2.build!(first_name: "Romain", last_name: "Commandé", age: age)

      assert person.first_name == "Romain"
      assert person.last_name == "Commandé"
      assert person.age == age
    end
  end

  describe "PersonFactory3" do
    test "builds a person shoud return an error" do
      result = PersonFactory3.build()

      assert result == {:error, %RuntimeError{message: "boom!"}}
    end

    test "builds a person with build!/1 should raises an exception" do
      assert_raise RuntimeError, fn ->
        PersonFactory3.build!()
      end
    end

    test "builds a person with the problematic field overrided should be ok" do
      {:ok, person} = PersonFactory3.build(age: 42)

      assert person.first_name == "John"
      assert person.last_name == "Doe"
      assert person.age == 42
    end

    test "builds a person with the problematic field overrided should return a person" do
      person = PersonFactory3.build!(age: 42)

      assert person.first_name == "John"
      assert person.last_name == "Doe"
      assert person.age == 42
    end
  end
end
