defmodule Risotto.SubfactoryTest do
  use ExUnit.Case

  defmodule ASubSubStruct do
    @moduledoc """
    level 3
    """
    defstruct [:value]
  end

  defmodule ASubStruct do
    @moduledoc """
    level 2
    """
    defstruct [:subfield, :value]
  end

  defmodule AStruct do
    @moduledoc """
    level 1
    """
    defstruct [:field, :value]
  end

  defmodule ASubSubStructFactory do
    use Risotto

    factory ASubSubStruct do
      field(:value, 42)
    end
  end

  defmodule ASubStructFactory do
    use Risotto

    factory ASubStruct do
      field(:subfield, subfactory(ASubSubStructFactory))
      field(:value, 42)
    end
  end

  defmodule AStructFactory do
    use Risotto

    factory AStruct do
      field(:field, subfactory(ASubStructFactory))
      field(:value, 42)
    end
  end

  defmodule ASubSubInvalidStructFactory do
    use Risotto

    factory ASubSubStruct do
      field(:value, fn -> raise "boom" end)
    end
  end

  defmodule ASubInvalidStructFactory do
    use Risotto

    factory ASubStruct do
      field(:subfield, subfactory(ASubSubInvalidStructFactory))
      field(:value, 42)
    end
  end

  defmodule AInvalidStructFactory do
    use Risotto

    factory AStruct do
      field(:field, subfactory(ASubInvalidStructFactory))
      field(:value, 42)
    end
  end

  describe "AStructFactory.build/1" do
    test "Should build a AStruct struct with default values" do
      result = AStructFactory.build!()

      assert result.value == 42
      assert result.field.value == 42
      assert result.field.subfield.value == 42
    end

    test "Should build a AStruct struct with value at first level overrided" do
      result = AStructFactory.build!(value: 43)

      assert result.value == 43
      assert result.field.value == 42
      assert result.field.subfield.value == 42
    end

    test "Should build a AStruct struct with value at second level overrided" do
      result = AStructFactory.build!(field__value: 43)

      assert result.value == 42
      assert result.field.value == 43
      assert result.field.subfield.value == 42
    end

    test "Should build a AStruct struct with value at third level overrided" do
      result = AStructFactory.build!(field__subfield__value: 43)

      assert result.value == 42
      assert result.field.value == 42
      assert result.field.subfield.value == 43
    end

    test "Should build a AStruct struct with all values overrided" do
      result =
        AStructFactory.build!(
          value: 43,
          field__value: 44,
          field__subfield__value: 45
        )

      assert result.value == 43
      assert result.field.value == 44
      assert result.field.subfield.value == 45
    end

    test "Should build a AStruct struct with just one level" do
      result =
        AStructFactory.build!(field: "no substruct here")

      assert result.value == 42
      assert result.field == "no substruct here"
    end
  end

  describe "AInvalidStructFactory.build/1" do
    test "Shoud raise an exception" do
      assert_raise RuntimeError, fn ->
        AInvalidStructFactory.build!()
      end
    end
  end
end
