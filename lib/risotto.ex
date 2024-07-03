defmodule Risotto do
  @moduledoc """
  Documentation for `Risotto`.
  """

  alias Risotto.Builder
  alias Risotto.CounterManager

  defmacro __using__(_) do
    quote do
      import Risotto
      CounterManager.start_link(nil)
    end
  end

  defmacro field(name, value) do
    quote do
      handle_field(unquote(name), unquote(value))
    end
  end

  def handle_field(name, {:subfactory, struct, opts}) do
    {:subfactory, name, struct, opts}
  end

  def handle_field(name, {:lazy, func}) do
    {:lazy, name, func}
  end

  def handle_field(name, {:sequence, id, func, start, pas}) do
    CounterManager.register(id, name, start, pas)
    {:sequence, id, name, func}
  end

  def handle_field(name, value) when is_function(value) do
    {:value, name, value}
  end

  def handle_field(name, value) do
    {:value, name, fn -> value end}
  end

  defmacro factory(struct, do: {:field, _c, _fields} = fields) do
    handle_factory(struct, {:__block__, [], [fields]})
  end

  defmacro factory(struct, do: {_t, _c, _fields} = expression) do
    handle_factory(struct, expression)
  end

  # sobelow_skip ["DOS.StringToAtom"]
  defp handle_factory(struct, {t, c, fields}) do
    new_expression = {t, c, [fields]}

    quote do
      def build!(opts \\ []) do
        Builder.build!(unquote(struct), unquote(new_expression), opts)
      end

      def build(opts \\ []) do
        Builder.build(unquote(struct), unquote(new_expression), opts)
      end
    end
  end

  defmacro subfactory(module, opts \\ []) do
    quote do
      {:subfactory, unquote(module), unquote(opts)}
    end
  end

  defmacro lazy(func) do
    quote do
      {:lazy, unquote(func)}
    end
  end

  defmacro sequence(opts \\ []) do
    id = UUID.uuid4()
    start = Keyword.get(opts, :start, 1)
    pas = Keyword.get(opts, :pas, 1)

    func =
      Keyword.get(
        opts,
        :func,
        quote do
          fn index -> index end
        end
      )

    quote do
      {:sequence, unquote(id), unquote(func), unquote(start), unquote(pas)}
    end
  end
end
