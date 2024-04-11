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
      handle_field(unquote(name), unquote(value))
    end
  end

  def handle_field(name, {:subfactory, struct, opts}) do
    {:subfactory, name, struct, opts}
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

  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  # sobelow_skip ["DOS.StringToAtom"]
  defp handle_factory(struct, {t, c, fields}) do
    new_expression = {t, c, [fields]}

    quote do
      def build!(opts \\ []) do
        unquote(new_expression)
        |> create_tasks(opts)
        |> Task.await_many()
        |> get_values_or_raise()
        |> then(&struct(unquote(struct), &1))
      end

      def build(opts \\ []) do
        build!(opts)
        |> then(fn builded -> {:ok, builded} end)
      rescue
        e -> {:error, e}
      end

      defp create_tasks(expressions, opts) do
        Enum.map(expressions, fn exp ->
          Task.async(fn ->
            try do
              {:ok, build_key_value(exp, opts)}
            rescue
              e ->
                {:error, {e, __STACKTRACE__}}
            end
          end)
        end)
      end

      defp get_values_or_raise(task_results) do
        Enum.map(task_results, fn {res, val} ->
          if res == :ok, do: val, else: reraise(elem(val, 0), elem(val, 1))
        end)
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
          {atom_fieldname, module.build!(merged_opts)}
        end
      end

      defp build_key_value({:value, name, func}, opts) do
        if Keyword.has_key?(opts, name) do
          {name, Keyword.get(opts, name)}
        else
          {name, func.()}
        end
      end
    end
  end

  defmacro subfactory(module, opts \\ []) do
    quote do
      {:subfactory, unquote(module), unquote(opts)}
    end
  end
end
