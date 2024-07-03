defmodule Risotto.SequenceTest do
  use ExUnit.Case, sync: true

  alias Risotto.CounterManager

  defmodule User do
    @enforce_keys [:id, :username, :email, :login]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            id: non_neg_integer(),
            username: String.t(),
            email: String.t(),
            login: String.t()
          }
  end

  defmodule UserFactory do
    @moduledoc """
    A factory for the `User` struct containing an ID as a sequence.
    """
    use Risotto

    factory User do
      field(:id, sequence(start: 1, pas: 2))
      field(:username, "johndoe")
      field(:email, "johndoe@example.com")
      field(:login, sequence(func: fn index -> "user_#{index}" end, pas: 2))
    end
  end

  setup_all do
    {:ok, pid} = start_supervised({CounterManager, [nil]})
    {:ok, counter: pid}
  end

  test "Shoud build a User struct", context do
    user = UserFactory.build!(risotto_cfg: [counter: context.counter])

    assert is_integer(user.id)
    assert user.username == "johndoe"
    assert user.email == "johndoe@example.com"
    assert user.login == "user_#{user.id}"
  end

  test "Shoud build 2 Users struct with different ids", context do
    user = UserFactory.build!(risotto_cfg: [counter: context.counter])
    user2 = UserFactory.build!(risotto_cfg: [counter: context.counter])

    assert user.id != user2.id
    assert user2.id == user.id + 2
  end
end
