defmodule Risotto do
  @moduledoc """
  Documentation for `Risotto`.
  """

  @callback default() :: Map.t()

  defp read_key(key) do
    string_key = Atom.to_string(key)

    if String.starts_with?(string_key, ":") do
      string_key
      |> String.replace_prefix(":", "")
      |> String.to_atom()
    else
      string_key
    end
  end

  def overriden_key(key, opts) do
    opts
    |> Keyword.keys()
    |> Stream.map(fn key -> {key, read_key(key)} end)
    |> Stream.filter(fn {_original, readed} -> readed == key end)
    |> Stream.take(1)
    |> Enum.map(fn {original, _readed} -> original end)
    |> List.first()
  end

  def build(factory, opts) do
    factory.default()
    |> Enum.reduce(%{fields: %{}, lazy: []}, fn {key, value}, acc ->
      case value do
        {:lazy, fun} ->
          put_in(acc, [:lazy], acc.lazy ++ [{key, fun}])

        _other ->
          overriden_key = overriden_key(key, opts)

          if overriden_key do
            put_in(acc, [:fields, key], opts[overriden_key])
          else
            put_in(acc, [:fields, key], build_field(value))
          end
      end
    end)
    |> then(fn values ->
      values.lazy
      |> Enum.map(fn {key, fun} ->
        value = build_lazy(values.fields, fun)
        {key, value}
      end)
      |> Map.new()
      |> Map.merge(values.fields)
    end)
  end

  def subfactory(factory_module), do: {:subfactory, factory_module}
  def lazy(fun), do: {:lazy, fun}
  def list(factory_module, opts \\ []), do: {:list, factory_module, opts}

  def build_field({:subfactory, mod}), do: build(mod, [])
  def build_field({:list, mod, opts}), do: build_list(mod, opts)
  def build_field(value), do: value

  def build_lazy(values, fun), do: fun.(values)
  def build_list(mod, count: count), do: Enum.map(1..count, fn _ -> build(mod, []) end)

  defmacro __using__(_opts) do
    quote do
      @behaviour Risotto

      def build(opts) do
        Risotto.build(__MODULE__, opts)
      end

      def build(), do: build([])
    end
  end
end
