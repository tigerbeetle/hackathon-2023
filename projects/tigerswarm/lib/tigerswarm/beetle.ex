defmodule TigerSwarm.Beetle do
  use Task

  alias TigerBeetlex.Account
  alias TigerBeetlex.Transfer
  alias TigerSwarm.Beetle

  @sleep_time 100
  @randomization_factor 0.25

  def spawn(id) do
    Task.Supervisor.start_child(Beetle.Supervisor, __MODULE__, :blast, [], name: via_tuple(id))
  end

  defp via_tuple(id) do
    {:via, Registry, {Beetle.Registry, id}}
  end

  def blast do
    account_1 = %Account{id: Uniq.UUID.uuid7(:raw), ledger: 1, code: 1}
    account_2 = %Account{id: Uniq.UUID.uuid7(:raw), ledger: 1, code: 1}

    :ok = TigerSwarm.Client.create_account(account_1)
    :ok = TigerSwarm.Client.create_account(account_2)

    transfer_forever(account_1.id, account_2.id)
  end

  defp transfer_forever(credit_account_id, debit_account_id) do
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

    @sleep_time
    |> randomized_timeout(@randomization_factor)
    |> Process.sleep()

    # Swap them back and forth
    transfer_forever(debit_account_id, credit_account_id)
  end

  # Returns base_timeout +/- randomization_factor
  defp randomized_timeout(base_timeout, randomization_factor) do
    round(base_timeout + (:rand.uniform() - 0.5) * randomization_factor * 2 * base_timeout)
  end
end
