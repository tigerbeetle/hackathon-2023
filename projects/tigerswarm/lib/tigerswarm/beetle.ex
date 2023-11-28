defmodule TigerSwarm.Beetle do
  use GenServer

  alias TigerBeetlex.Account
  alias TigerBeetlex.Transfer
  alias TigerSwarm.Beetle

  @request_interval 100
  @randomization_factor 0.25

  def start_link(opts) do
    id = Keyword.fetch!(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: via_tuple(id))
  end

  def via_tuple(id) do
    {:via, Registry, {Beetle.Registry, id}}
  end

  @impl true
  def init(_opts) do
    state = %{
      credit_account_id: Uniq.UUID.uuid7(:raw),
      debit_account_id: Uniq.UUID.uuid7(:raw)
    }

    {:ok, state, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, state) do
    %{
      credit_account_id: credit_account_id,
      debit_account_id: debit_account_id
    } = state

    account_1 = %Account{id: credit_account_id, ledger: 1, code: 1}
    account_2 = %Account{id: debit_account_id, ledger: 1, code: 1}

    :ok = TigerSwarm.Client.create_account(account_1)
    :ok = TigerSwarm.Client.create_account(account_2)

    schedule_next_transfer()

    {:noreply, state}
  end

  @impl true
  def handle_info(:transfer, state) do
    %{
      credit_account_id: credit_account_id,
      debit_account_id: debit_account_id
    } = state

    :ok =
      %Transfer{
        id: Uniq.UUID.uuid7(:raw),
        credit_account_id: credit_account_id,
        debit_account_id: debit_account_id,
        ledger: 1,
        code: 1,
        amount: 100
      }
      |> TigerSwarm.Client.create_transfer()

    schedule_next_transfer()

    {:noreply, swap_accounts(state)}
  end

  defp swap_accounts(state) do
    %{
      credit_account_id: state.debit_account_id,
      debit_account_id: state.credit_account_id
    }
  end

  defp schedule_next_transfer do
    Process.send_after(
      self(),
      :transfer,
      randomized_timeout(@request_interval, @randomization_factor)
    )
  end

  # Returns base_timeout +/- randomization_factor
  defp randomized_timeout(base_timeout, randomization_factor) do
    round(base_timeout + (:rand.uniform() - 0.5) * randomization_factor * 2 * base_timeout)
  end
end
