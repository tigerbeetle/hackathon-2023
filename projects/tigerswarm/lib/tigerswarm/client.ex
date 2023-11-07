defmodule TigerSwarm.Client do
  @moduledoc """
  This module exposes a blocking API to the TigerBeetle NIF client, which automatically batches
  requests. This is obtained by spawning a receiver process. The receiver processes handle receiving
  messages from the processless `TigerBeetlex` client and translate them in a blocking API.
  """

  alias TigerBeetlex.Account
  alias TigerBeetlex.Transfer
  alias TigerSwarm.Client.RequestBatcher

  def create_account(%Account{} = account) do
    dispatch_to_batcher(RequestBatcher.CreateAccount, account)
  end

  def create_transfer(%Transfer{} = transfer) do
    dispatch_to_batcher(RequestBatcher.CreateTransfer, transfer)
  end

  def lookup_account(<<_::1024>> = id) do
    dispatch_to_batcher(RequestBatcher.LookupAccount, id)
  end

  def lookup_transfer(<<_::1024>> = id) do
    dispatch_to_batcher(RequestBatcher.LookupTransfer, id)
  end

  defp dispatch_to_batcher(batcher, payload) do
    metadata = %{batcher: Process.whereis(batcher)}

    :telemetry.span([:tigerswarm, :request], metadata, fn ->
      result = GenStateMachine.call(batcher, {:new_request, payload})
      {result, metadata}
    end)
  end
end
