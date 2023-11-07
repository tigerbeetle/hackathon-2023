defmodule TigerSwarm.Client.RequestBatcher do
  use GenStateMachine

  alias TigerBeetlex.Response

  defmodule Data do
    defstruct batch: nil,
              batch_index_to_from: %{},
              batch_size: nil,
              batch_type: nil,
              batch_queue: :queue.new(),
              batch_start_time: nil,
              client: nil,
              concurrency_max: nil,
              current_batch_index: 0,
              in_flight_requests: 0,
              next_batch_size: nil,
              request_ref_to_callers: %{},
              submit_fun: nil
  end

  # TODO: experiment with this
  @batch_timeout_ms 50

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenStateMachine.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    cluster_id = Keyword.fetch!(opts, :cluster_id)
    addresses = Keyword.fetch!(opts, :addresses)
    concurrency_max = Keyword.fetch!(opts, :concurrency_max)

    batch_type = Keyword.fetch!(opts, :batch_type)
    batch_size = Keyword.fetch!(opts, :batch_size)
    submit_fun = Keyword.fetch!(opts, :submit_fun)

    with {:ok, client} <- TigerBeetlex.connect(cluster_id, addresses, concurrency_max) do
      initial_data =
        %Data{
          batch_size: batch_size,
          batch_type: batch_type,
          client: client,
          concurrency_max: concurrency_max,
          next_batch_size: batch_size,
          submit_fun: submit_fun
        }
        |> reset_batch()

      {:ok, :flowing, initial_data}
    end
  end

  @impl true
  def handle_event(:enter, _old_state, :prioritizing_responses, _data) do
    {:keep_state_and_data, prioritizing_responses_timeout_action()}
  end

  def handle_event(:enter, _old_state, _state, _data) do
    :keep_state_and_data
  end

  def handle_event({:call, from}, {:update_batch_size, batch_size}, _state, data) do
    {:keep_state, put_next_batch_size(data, batch_size), {:reply, from, :ok}}
  end

  def handle_event({:call, _from}, {:new_request, _payload}, :prioritizing_responses, _data) do
    # Prioritize receiving responses, postponing new calls
    {:keep_state_and_data, :postpone}
  end

  def handle_event({:call, from}, {:new_request, payload}, state, data) do
    new_data =
      data
      |> insert_caller(from)
      |> append_batch_item(payload)

    case state do
      :flowing ->
        if batch_full?(new_data) do
          {:next_state, :prioritizing_responses, new_data, submit_current_batch_action()}
        else
          maybe_start_batch_timeout(new_data)

          {:keep_state, new_data}
        end

      :enqueueing ->
        new_data =
          if batch_full?(new_data) do
            new_data
            |> enqueue_batch()
            |> reset_batch()
          else
            new_data
          end

        {:next_state, :prioritizing_responses, new_data}
    end
  end

  def handle_event(:internal, {:submit_queued_batch, batch_tuple}, _state, data) do
    {batch, batch_index_to_from, batch_start_time} = batch_tuple
    new_data = submit_batch(data, batch, batch_index_to_from, batch_start_time)

    {:next_state, :prioritizing_responses, new_data}
  end

  def handle_event(:internal, :submit_current_batch, _state, data) do
    %{
      batch: batch,
      batch_index_to_from: batch_index_to_from,
      batch_start_time: batch_start_time
    } = data

    new_data =
      data
      |> submit_batch(batch, batch_index_to_from, batch_start_time)
      |> reset_batch()

    {:next_state, :prioritizing_responses, new_data}
  end

  def handle_event(:info, {:batch_timeout, batch}, _state, %{batch: batch}) do
    {:keep_state_and_data, submit_current_batch_action()}
  end

  def handle_event(:info, {:batch_timeout, _batch}, _state, _data) do
    :keep_state_and_data
  end

  def handle_event(:info, {:tigerbeetlex_response, ref, response}, state, data) do
    %{
      request_ref_to_callers: request_ref_to_callers
    } = data

    actions =
      reply_actions(request_ref_to_callers, ref, response)

    new_data = release_request(data, ref)

    case state do
      :flowing ->
        {:keep_state, new_data, actions}

      :prioritizing_responses ->
        case dequeue_batch(new_data) do
          {new_data, nil} ->
            {:next_state, :flowing, new_data, actions}

          {new_data, batch_tuple} ->
            {:keep_state, new_data, [submit_queued_batch_action(batch_tuple) | actions]}
        end
    end
  end

  def handle_event(:state_timeout, :resume, :prioritizing_responses, data) do
    if can_process_more_requests?(data) do
      {:next_state, :flowing, data}
    else
      {:next_state, :enqueueing, data}
    end
  end

  ### Helpers to generate internal actions

  defp submit_current_batch_action do
    {:next_event, :internal, :submit_current_batch}
  end

  defp submit_queued_batch_action(batch_tuple) do
    {:next_event, :internal, {:submit_queued_batch, batch_tuple}}
  end

  defp prioritizing_responses_timeout_action do
    {:state_timeout, 0, :resume}
  end

  defp reply_actions(request_ref_to_callers, ref, response) do
    batch_index_to_from = Map.fetch!(request_ref_to_callers, ref)
    {:ok, response} = Response.to_stream(response)

    # FIXME: we're assuming CreateAccount/CreateTransfer here right now

    {replies, remaining_froms} =
      Enum.reduce(response, {[], batch_index_to_from}, fn create_error,
                                                          {error_replies, batch_index_to_from} ->
        %{index: index, reason: reason} = create_error
        {from, batch_index_to_from} = Map.pop!(batch_index_to_from, index)
        reply = {:reply, from, {:error, reason}}
        {[reply | error_replies], batch_index_to_from}
      end)

    remaining_froms
    |> Map.values()
    |> Enum.reduce(replies, fn from, replies ->
      reply = {:reply, from, :ok}
      [reply | replies]
    end)
  end

  ### Other Helpers

  defp maybe_start_batch_timeout(data) do
    %{
      batch: batch,
      current_batch_index: current_batch_index
    } = data

    if current_batch_index == 1 do
      Process.send_after(self(), {:batch_timeout, batch}, @batch_timeout_ms)
    end

    :ok
  end

  ### Helpers to manipulate the state machine data

  defp put_next_batch_size(data, size) do
    %{data | next_batch_size: size}
  end

  defp batch_full?(data) do
    data.current_batch_index >= data.batch_size
  end

  defp can_process_more_requests?(data) do
    data.concurrency_max > data.in_flight_requests
  end

  defp reset_batch(data) do
    %{
      batch_type: batch_type,
      next_batch_size: batch_size
    } = data

    %{
      data
      | current_batch_index: 0,
        batch_index_to_from: %{},
        batch_size: batch_size,
        batch: batch_type.new!(batch_size)
    }
  end

  defp submit_batch(data, batch, batch_index_to_from, batch_start_time) do
    %{
      client: client,
      in_flight_requests: in_flight_requests,
      request_ref_to_callers: request_ref_to_callers,
      submit_fun: submit_fun
    } = data

    duration = System.monotonic_time() - batch_start_time
    metadata = %{batcher: self()}

    :telemetry.execute([:tigerswarm, :batch, :stop], %{duration: duration}, metadata)

    {:ok, ref} = apply(TigerBeetlex, submit_fun, [client, batch])

    %{
      data
      | in_flight_requests: in_flight_requests + 1,
        request_ref_to_callers: Map.put(request_ref_to_callers, ref, batch_index_to_from)
    }
  end

  defp release_request(data, ref) do
    %{
      in_flight_requests: in_flight_requests,
      request_ref_to_callers: request_ref_to_callers
    } = data

    %{
      data
      | in_flight_requests: in_flight_requests - 1,
        request_ref_to_callers: Map.delete(request_ref_to_callers, ref)
    }
  end

  defp insert_caller(data, from) do
    %{
      current_batch_index: current_batch_index,
      batch_index_to_from: batch_index_to_from
    } = data

    %{data | batch_index_to_from: Map.put(batch_index_to_from, current_batch_index, from)}
  end

  defp enqueue_batch(data) do
    %{
      batch: batch,
      batch_index_to_from: batch_index_to_from,
      batch_start_time: batch_start_time,
      batch_queue: batch_queue
    } = data

    batch_tuple = {batch, batch_index_to_from, batch_start_time}

    %{data | batch_queue: :queue.in(batch_tuple, batch_queue)}
  end

  defp dequeue_batch(data) do
    %{
      batch_queue: batch_queue
    } = data

    case :queue.out(batch_queue) do
      {:empty, _batch_queue} ->
        {data, nil}

      {{:value, batch_tuple}, batch_queue} ->
        {%{data | batch_queue: batch_queue}, batch_tuple}
    end
  end

  defp append_batch_item(data, item) do
    %{
      batch: batch,
      batch_type: batch_type,
      current_batch_index: current_batch_index
    } = data

    new_data =
      %{
        data
        | batch: batch_type.append!(batch, item),
          current_batch_index: current_batch_index + 1
      }

    if current_batch_index == 0 do
      start_time = System.monotonic_time()
      metadata = %{batcher: self()}
      :telemetry.execute([:tigerswarm, :batch, :start], %{system_time: start_time}, metadata)
      %{new_data | batch_start_time: start_time}
    else
      new_data
    end
  end
end
