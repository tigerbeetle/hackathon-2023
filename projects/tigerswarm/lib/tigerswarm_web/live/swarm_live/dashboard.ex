defmodule TigerSwarmWeb.SwarmLive.Dashboard do
  use TigerSwarmWeb, :live_view

  alias TigerSwarm.Client
  alias TigerSwarm.Swarm

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :ok = subscribe("request_stats")
      :ok = subscribe("batch_stats")
    end

    initial_params = %{
      swarm_count: Swarm.get_count(),
      batch_size: Client.get_batch_size(),
      batch_timeout: Client.get_batch_timeout()
    }

    form =
      initial_params
      |> parameters_changeset(%{})
      |> to_form(as: :parameters)

    socket =
      socket
      |> assign(:page_title, "TigerSwarm")
      |> assign(:parameters, initial_params)
      |> assign(:form, form)

    {:ok, socket}
  end

  @impl true
  def handle_info({TigerSwarmWeb.SwarmLive.FormComponent, {:saved, swarm}}, socket) do
    {:noreply, stream_insert(socket, :swarms, swarm)}
  end

  def handle_info({:batch_stats, batch_stats}, socket) do
    {:noreply, assign(socket, :batch_stats, batch_stats)}
  end

  def handle_info({:request_stats, request_stats}, socket) do
    {:noreply, assign(socket, :request_stats, request_stats)}
  end

  @impl true
  def handle_event("validate", %{"parameters" => params}, socket) do
    form =
      socket.assigns.parameters
      |> parameters_changeset(params)
      |> Map.put(:action, :insert)
      |> to_form(as: :parameters)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("update", %{"parameters" => params}, socket) do
    changeset =
      socket.assigns.parameters
      |> parameters_changeset(params)

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, parameters} ->
        Enum.each(changeset.changes, &apply_parameter_change/1)

        {:noreply,
         assign(socket, parameters: parameters, form: to_form(changeset, as: :parameters))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :parameters))}
    end
  end

  defp subscribe(topic) do
    Phoenix.PubSub.subscribe(TigerSwarm.PubSub, topic)
  end

  defp apply_parameter_change({:swarm_count, count}) do
    Swarm.scale_to(count)
  end

  defp apply_parameter_change({:batch_size, size}) do
    Client.update_batch_size(size)
  end

  defp apply_parameter_change({:batch_timeout, timeout}) do
    Client.update_batch_timeout(timeout)
  end

  defp parameters_changeset(data, attrs) do
    types = %{swarm_count: :integer, batch_size: :integer, batch_timeout: :integer}

    {data, types}
    |> Ecto.Changeset.cast(attrs, Map.keys(types))
    |> Ecto.Changeset.validate_number(:swarm_count, greater_than_or_equal_to: 0)
    |> Ecto.Changeset.validate_number(:batch_timeout, greater_than_or_equal_to: 0)
    |> Ecto.Changeset.validate_number(:batch_size, greater_than: 0, less_than_or_equal_to: 8191)
  end
end
