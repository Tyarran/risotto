defmodule RisottoTest do
  use ExUnit.Case

  defmodule TestSimpleFactory do
    use Risotto

    def default() do
      %{
        "name" => "Test",
        name: "Test"
      }
    end
  end

  defmodule TestAddressFactory do
    use Risotto

    def default do
      %{
        street: "Test Street",
        city: "Test City",
        country: "Test Country"
      }
    end
  end

  defmodule TestUserFactory do
    use Risotto

    def default do
      %{
        first_name: "test_first_name",
        last_name: "test_last_name",
        age: 42,
        address: Risotto.subfactory(TestAddressFactory),
        other_addresses: Risotto.list(TestAddressFactory, count: 2),
        name: Risotto.lazy(fn user -> "#{user.first_name} #{user.last_name}" end),
        name2: Risotto.lazy(&name2/1)
      }
    end

    def name2(user_data) do
      "#{user_data.first_name} #{user_data.last_name}"
    end
  end

  describe "Build flat data with TestSimpleFactory" do
    test "- default values" do
      result = TestSimpleFactory.build()

      assert result == %{
               "name" => "Test",
               name: "Test"
             }
    end

    test "- override values (atom field)" do
      result = TestSimpleFactory.build(name: "overrided name")

      assert result == %{
               "name" => "Test",
               name: "overrided name"
             }
    end

    test "- override values (binary field)" do
      result = TestSimpleFactory.build(_name: "overrided name")

      assert result == %{
               "name" => "overrided name",
               name: "Test"
             }
    end
  end

  describe "Build data with TestUserFactory" do
    test "- default values" do
      result = TestUserFactory.build()

      assert result == %{
               first_name: "test_first_name",
               last_name: "test_last_name",
               age: 42,
               address: %{
                 street: "Test Street",
                 city: "Test City",
                 country: "Test Country"
               },
               other_addresses: [
                 %{street: "Test Street", city: "Test City", country: "Test Country"},
                 %{street: "Test Street", city: "Test City", country: "Test Country"}
               ],
               name: "test_first_name test_last_name",
               name2: "test_first_name test_last_name"
             }
    end
  end
end
