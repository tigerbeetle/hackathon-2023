defmodule TigerSwarm.Swarm do
  use DynamicSupervisor

  alias TigerSwarm.Beetle

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def scale_to(count) do
    current_count =
      DynamicSupervisor.count_children(__MODULE__)
      |> Map.fetch!(:workers)

    scale(current_count, count)
  end

  defp scale(current, target) when target == current, do: :ok

  defp scale(current, target) when target > current do
    (current + 1)..target
    |> Enum.each(fn id ->
      DynamicSupervisor.start_child(__MODULE__, {Beetle, id: id})
    end)
  end

  defp scale(current, target) when target < current do
    (target + 1)..current
    |> Enum.each(fn id ->
      [{pid, _}] = Registry.lookup(Beetle.Registry, id)
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
