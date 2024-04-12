defmodule Risotto.LazyAttributeTest do
  use ExUnit.Case

  defmodule Person do
    @enforce_keys [:first_name, :last_name, :full_name, :age]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            first_name: String.t(),
            last_name: String.t(),
            full_name: String.t(),
            age: non_neg_integer()
          }
  end

  defmodule PersonFactory do
    @moduledoc """
    A factory for the `Person` struct with a lazy attribute.
    """
    use Risotto

    factory Person do
      field(:first_name, "John")
      field(:last_name, "Doe")
      field(:full_name, lazy(&full_name/1))
      field(:age, 42)
    end

    def full_name(data) do
      first_name = Keyword.get(data, :first_name)
      last_name = Keyword.get(data, :last_name)

      "#{first_name} #{last_name}"
    end
  end

  defmodule PersonFactory2 do
    @moduledoc """
    A factory for the `Person` struct with a bad lazy attribute.
    """
    use Risotto

    factory Person do
      field(:first_name, "John")
      field(:last_name, "Doe")
      field(:full_name, lazy(&full_name/1))
      field(:age, 42)
    end

    def full_name(_data) do
      raise "Boom!"
    end
  end

  @tag :debug
  test "Should build a person with a lazy attribute" do
    person = PersonFactory.build!()

    assert person.first_name == "John"
    assert person.last_name == "Doe"
    assert person.full_name == "John Doe"
    assert person.age == 42
  end

  test "Should throw an exception due to a bad lazy attribute" do
    assert_raise RuntimeError, fn ->
      PersonFactory2.build!()
    end
  end
end
