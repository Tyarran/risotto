defmodule Risotto do
  @moduledoc """
  Documentation for `Risotto`.
  """

  @callback default() :: Map.t()

  def build(factory) do
    factory.default()
    |> Enum.reduce(%{fields: %{}, lazy: []}, fn {key, value}, acc ->
      case value do
        {:lazy, fun} -> put_in(acc, [:lazy], acc.lazy ++ [{key, fun}])
        _other -> put_in(acc, [:fields, key], build_field(value))
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

  def build_field({:subfactory, mod}), do: build(mod)
  def build_field({:list, mod, opts}), do: build_list(mod, opts)
  def build_field(value), do: value

  def build_lazy(values, fun), do: fun.(values)

  def build_list(mod, count: count) do
    Enum.map(1..count, fn _ -> build(mod) end)
  end
end
