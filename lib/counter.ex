defmodule Risotto.CounterManager do
  @moduledoc false
  use Agent

  defmodule Context do
    @moduledoc false

    defmodule Counter do
      @moduledoc false
      defstruct [:fieldname, :count, :pas, :initial]
    end
  end

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def register(id, fieldname, start, pas) do
    Agent.update(__MODULE__, fn state ->
      if Map.has_key?(state, id) do
        state
      else
        Map.put(state, id, %Context.Counter{
          fieldname: fieldname,
          count: start,
          pas: pas,
          initial: start
        })
      end
    end)
  end

  def next(id) do
    Agent.get_and_update(__MODULE__, fn state ->
      %Context.Counter{count: count, pas: pas} = value = Map.get(state, id)
      new_counter = %{value | count: count + pas}
      {count, Map.put(state, id, new_counter)}
    end)
  end
end
