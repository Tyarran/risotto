defmodule Risotto.Factories do
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

  #
  defmodule Test do
    require Risotto.Factory

    alias Risotto.Factory

    # def default() do
    #   %{}
    # end

    # def test() do
    #   Factory.build(
    #     TestUserFactory,
    #     first_name: "overriden"
    #   )
    # end
  end
end
