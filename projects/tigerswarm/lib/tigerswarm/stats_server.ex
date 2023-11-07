defmodule TigerSwarm.StatsServer do
  use GenServer

  require Logger

  alias TigerSwarm.BatchStats
  alias TigerSwarm.RequestStats
  alias TigerSwarm.StatsServer

  defmodule State do
    defstruct started_request_count: 0,
              finished_requests: [],
              started_batch_count: 0,
              finished_batches: []
  end

  @stats_interval :timer.seconds(1)

  def start_link(arg) do
    :ok =
      :telemetry.attach_many(
        # unique handler id
        "stats-server",
        [
          [:tigerswarm, :request, :stop],
          [:tigerswarm, :batch, :stop]
        ],
        &StatsServer.handle_event/4,
        nil
      )

    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def handle_event([:tigerswarm, :request, :stop], %{duration: duration}, _metadata, _config) do
    GenServer.cast(__MODULE__, {:request_stop, duration})
  end

  def handle_event([:tigerswarm, :batch, :stop], %{duration: duration}, _metadata, _config) do
    GenServer.cast(__MODULE__, {:batch_stop, duration})
  end

  def init(_arg) do
    Process.send_after(self(), :emit_stats, @stats_interval)
    {:ok, %State{}}
  end

  def handle_cast({:request_stop, duration}, state) do
    ms_duration = System.convert_time_unit(duration, :native, :millisecond)
    {:noreply, Map.update!(state, :finished_requests, &[ms_duration | &1])}
  end

  def handle_cast({:batch_stop, duration}, state) do
    ms_duration = System.convert_time_unit(duration, :native, :millisecond)
    {:noreply, Map.update!(state, :finished_batches, &[ms_duration | &1])}
  end

  def handle_info(:emit_stats, state) do
    %{
      finished_requests: finished_requests,
      finished_batches: finished_batches
    } = state

    if finished_requests != [] do
      request_stats = %RequestStats{
        interval: @stats_interval,
        stats: Statistex.statistics(finished_requests, percentiles: [90, 95, 99, 99.9])
      }

      broadcast("request_stats", {:request_stats, request_stats})
    end

    if finished_batches != [] do
      batch_stats = %BatchStats{
        interval: @stats_interval,
        stats: Statistex.statistics(finished_batches, percentiles: [90, 95, 99, 99.9])
      }

      broadcast("batch_stats", {:batch_stats, batch_stats})
    end

    Process.send_after(self(), :emit_stats, @stats_interval)

    new_state =
      %{
        state
        | finished_requests: [],
          finished_batches: []
      }

    {:noreply, new_state}
  end

  defp broadcast(topic, payload) do
    Phoenix.PubSub.broadcast(TigerSwarm.PubSub, topic, payload)
  end
end
