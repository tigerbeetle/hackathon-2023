defmodule TigerSwarm.StatsServer do
  use GenServer

  require Logger

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

    request_count = Enum.count(finished_requests)
    batch_count = Enum.count(finished_batches)

    Logger.info("Requests per second: #{request_count}")
    Logger.info("Batches per second: #{batch_count}")
    Process.send_after(self(), :emit_stats, @stats_interval)

    if request_count > 0 do
      request_stats = Statistex.statistics(finished_requests, percentiles: [90, 95, 99, 99.9])
      Logger.info("Request average duration: #{request_stats.average}")
      Logger.info("Request stddev: #{request_stats.standard_deviation}")
      Logger.info("Request percentiles: #{inspect(request_stats.percentiles)}")
    end

    if batch_count > 0 do
      batch_stats = Statistex.statistics(finished_batches, percentiles: [90, 95, 99, 99.9])
      Logger.info("Batch average duration: #{batch_stats.average}")
      Logger.info("Batch stddev: #{batch_stats.standard_deviation}")
      Logger.info("Batch percentiles: #{inspect(batch_stats.percentiles)}")
    end

    new_state =
      %{
        state
        | finished_requests: [],
          finished_batches: []
      }

    {:noreply, new_state}
  end
end
