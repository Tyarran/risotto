defmodule OptParserTest do
  use ExUnit.Case, async: true

  alias Risotto.OptParser

  test "parse simple atom key" do
    opt = [field: "ok"]

    result = OptParser.parse(opt)

    assert result == %{values: %{field: "ok"}, params: %{}}
  end

  test "parse 2 simple atom key" do
    opt = [field: "ok", field2: "ok"]

    result = OptParser.parse(opt)

    assert result == %{values: %{field: "ok", field2: "ok"}, params: %{}}
  end

  test "parse simple atom key with underscore in this name" do
    opt = [field_name: "ok"]

    result = OptParser.parse(opt)

    assert result == %{values: %{field_name: "ok"}, params: %{}}
  end

  test "parse simple atom key with double underscore in this name" do
    opt = ["{field__name}__subfield": "ok"]

    result = OptParser.parse(opt)

    assert result == %{values: %{}, params: %{field__name: [subfield: "ok"]}}
  end

  test "parse simple atom key with double underscore in this name at subkey" do
    opt = ["field_name__{subfield__name}__other_subfield": "ok"]

    result = OptParser.parse(opt)

    assert result == %{
             values: %{},
             params: %{field_name: ["{subfield__name}__other_subfield": "ok"]}
           }
  end

  test "parse simple string key" do
    opt = [_field: "ok"]

    result = OptParser.parse(opt)

    assert result == %{values: %{"field" => "ok"}, params: %{}}
  end

  test "parse 2 simple string key" do
    opt = [_field: "ok", _field2: "ok"]

    result = OptParser.parse(opt)

    assert result == %{values: %{"field" => "ok", "field2" => "ok"}, params: %{}}
  end

  test "parse 1 simple string key and 1 simple atom key" do
    opt = [_field: "ok", field2: "ok"]

    result = OptParser.parse(opt)

    assert result == %{values: %{"field" => "ok", field2: "ok"}, params: %{}}
  end

  test "parse a key with a subkey as atom" do
    opt = [field__subfield: "ok"]

    result = OptParser.parse(opt)

    assert result == %{values: %{}, params: %{field: [subfield: "ok"]}}
  end

  test "parse a key with a subkey as string" do
    opt = [field___subfield: "ok"]

    result = OptParser.parse(opt)

    assert result == %{values: %{}, params: %{field: [_subfield: "ok"]}}
  end

  test "parse a key with 2 subkeys as string" do
    opt = [field___subfield: "ok"]

    result = OptParser.parse(opt)

    assert result == %{values: %{}, params: %{field: [_subfield: "ok"]}}
  end
end
