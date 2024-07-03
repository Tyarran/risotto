defmodule Risotto.Builder do
  @moduledoc false

  alias Risotto.CounterManager

  def build(struct, expressions, opts \\ []) do
    build!(struct, expressions, opts)
    |> then(fn builded -> {:ok, builded} end)
  rescue
    e -> {:error, e}
  end

  def build!(struct, expressions, opts \\ []) do
    {direct_expr, lazy_expr} = split_expressions(expressions)

    resolved =
      direct_expr
      |> create_direct_tasks(opts)
      |> Task.await_many()
      |> get_values_or_raise()

    resolved_lazy =
      lazy_expr
      |> create_lazy_tasks(resolved)
      |> Task.await_many()
      |> get_values_or_raise()

    struct(struct, resolved ++ resolved_lazy)
  end

  defp split_expressions(expressions) do
    Enum.split_with(expressions, fn expr ->
      elem(expr, 0) != :lazy
    end)
  end

  defp create_direct_tasks(expressions, opts) do
    Enum.map(expressions, fn exp ->
      create_resolve_task(fn -> build_key_value(exp, opts) end)
    end)
  end

  defp create_lazy_tasks(expressions, resolved) do
    Enum.map(expressions, fn {:lazy, fieldname, func} ->
      create_resolve_task(fn -> {fieldname, func.(resolved)} end)
    end)
  end

  defp create_resolve_task(func) do
    Task.async(fn ->
      try do
        {:ok, func.()}
      rescue
        e ->
          {:error, {e, __STACKTRACE__}}
      end
    end)
  end

  defp get_values_or_raise(task_results) do
    Enum.map(task_results, fn {res, val} ->
      if res == :ok, do: val, else: reraise(elem(val, 0), elem(val, 1))
    end)
  end

  defp build_key_value({:value, name, func}, opts) do
    if Keyword.has_key?(opts, name) do
      {name, Keyword.get(opts, name)}
    else
      {name, func.()}
    end
  end

  defp build_key_value({:sequence, id, name, func}, _opts) do
    count = CounterManager.next(id)
    value = func.(count)
    {name, value}
  end

  # sobelow_skip ["DOS.StringToAtom"]
  defp build_key_value({:subfactory, atom_fieldname, module, sub_opts}, opts) do
    name = Atom.to_string(atom_fieldname)

    value =
      Keyword.get(sub_opts, atom_fieldname) || Keyword.get(opts, atom_fieldname)

    if value do
      {atom_fieldname, value}
    else
      from_parent_opts =
        for {atom_key, value} <- opts,
            key = Atom.to_string(atom_key),
            String.starts_with?(key, name <> "__") do
          new_key =
            key
            |> String.replace_prefix(name <> "__", "")
            |> String.to_atom()

          {new_key, value}
        end

      merged_opts = Keyword.merge(sub_opts, from_parent_opts)

      # {atom_fieldname, module.build!(merged_opts, [])}
      {atom_fieldname, module.build!(merged_opts)}
      # {atom_fieldname, module.build!()}
    end
  end
end
