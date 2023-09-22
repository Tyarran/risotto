defmodule Risotto do
  @moduledoc """
  Documentation for `Risotto`.
  """
  alias Risotto.OptParser

  @callback default() :: Map.t()

  def build(factory, opts) do
    %{params: params, values: values} = OptParser.parse(opts)

    factory.default()
    |> Enum.reduce(%{fields: %{}, lazy: []}, fn {key, value}, acc ->
      case value do
        {:lazy, fun} ->
          put_in(acc, [:lazy], acc.lazy ++ [{key, fun}])

        _other ->
          override_value = values[key]

          if override_value do
            put_in(acc, [:fields, key], override_value)
          else
            put_in(acc, [:fields, key], build_field(value, Map.get(params, key, [])))
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

  def build_field({:subfactory, mod}, build_opts), do: build(mod, build_opts)
  def build_field({:list, mod, opts}, build_opts), do: build_list(mod, build_opts, opts)
  def build_field(value, _build_opts), do: value

  def build_lazy(values, fun), do: fun.(values)

  def build_list(mod, build_opts, count: count),
    do: Enum.map(1..count, fn _ -> build(mod, build_opts) end)

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
