defmodule Risotto do
  @moduledoc """
  Documentation for `Risotto`.
  """

  defmacro __using__(_) do
    quote do
      import Risotto
    end
  end

  defmacro field(name, value) do
    quote do
      value = unquote(value)
      new_value = if is_function(value), do: value, else: fn -> value end

      {:value, unquote(name), new_value}
    end
  end

  defmacro factory(struct, do: {t, c, fields}) do
    new_expression = {t, c, [fields]}

    quote do
      def build(opts \\ []) do
        unquote(new_expression)
        |> Enum.map(&build_key_value(&1, opts))
        |> then(&struct(unquote(struct), &1))
      end

      defp build_key_value(field, opts) do
        {:value, name, func} = field

        if Keyword.has_key?(opts, name) do
          {name, Keyword.get(opts, name)}
        else
          {name, func.()}
        end
      end
    end
  end
end
