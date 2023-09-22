defmodule Risotto.OptParser do
  @moduledoc """
  Module for options parser
  """

  def parse(opts \\ []) do
    opts
    |> Enum.map(fn {key, value} -> parse_param(key, value) end)
    |> Enum.reduce(%{values: %{}, params: %{}}, fn param, acc ->
      case param do
        {:value, {key, value}} ->
          put_in(acc, [:values, key], value)

        {:params, {key, params}} ->
          previous = Map.get(acc.params, key, [])
          put_in(acc, [:params, key], previous ++ params)
      end
    end)
  end

  defp read_key("{" <> field_name), do: String.replace_suffix(field_name, "}", "")
  defp read_key("__"), do: nil
  defp read_key(""), do: nil
  defp read_key(field_name), do: field_name

  defp build_key(key) do
    if String.contains?(key, "__") do
      "{" <> key <> "}"
    else
      key
    end
  end

  defp parse_param(key, value) do
    keys =
      key
      |> Atom.to_string()
      |> then(&Regex.split(~r/({.*}|__)/, &1, include_captures: true))
      |> Enum.map(&read_key/1)
      |> Enum.reject(&is_nil/1)

    case keys do
      [key] ->
        {:value, {decode_key(key), value}}

      [first | other_keys] ->
        sub_param =
          other_keys
          |> Enum.map_join("__", &build_key/1)
          |> String.to_atom()

        {:params, {decode_key(first), [{sub_param, value}]}}
    end
  end

  defp decode_key(key) do
    if String.starts_with?(key, "_") do
      String.replace_prefix(key, "_", "")
    else
      key
      |> String.to_atom()
    end
  end
end
