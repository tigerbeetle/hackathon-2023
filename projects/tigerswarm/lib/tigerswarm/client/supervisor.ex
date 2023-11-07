defmodule TigerSwarm.Client.Supervisor do
  use Supervisor

  alias TigerBeetlex.AccountBatch
  alias TigerBeetlex.IDBatch
  alias TigerBeetlex.TransferBatch
  alias TigerSwarm.Client.RequestBatcher

  @start_link_opts_schema [
    cluster_id: [
      type: :non_neg_integer,
      required: true,
      doc: "The TigerBeetle cluster id."
    ],
    addresses: [
      type: {:list, :string},
      required: true,
      doc: """
      The list of node addresses. These can either be a single digit (e.g. `"3000"`), which is
      interpreted as a port on `127.0.0.1`, an IP address + port (e.g. `"127.0.0.1:3000"`), or just
      an IP address (e.g. `"127.0.0.1"`), which defaults to port `3001`.
      """
    ],
    concurrency_max: [
      type: :pos_integer,
      required: true,
      doc: """
      The maximum number of concurrent requests the client can handle. 32 is a good default, and can
      be increased to 4096 if there's the need of increased throughput.
      """
    ],
    batch_size: [
      type: :non_neg_integer,
      required: true,
      doc: "The batch size",
      default: 1
    ]
  ]

  def start_link(opts) do
    opts = NimbleOptions.validate!(opts, @start_link_opts_schema)

    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    [
      {RequestBatcher.CreateAccount, AccountBatch, :create_accounts},
      {RequestBatcher.CreateTransfer, TransferBatch, :create_transfers},
      {RequestBatcher.LookupAccount, IDBatch, :lookup_accounts},
      {RequestBatcher.LookupTransfer, IDBatch, :lookup_transfers}
    ]
    |> Enum.map(fn {batcher_name, batch_type, submit_fun} ->
      opts =
        opts
        |> Keyword.put(:name, batcher_name)
        |> Keyword.put(:batch_type, batch_type)
        |> Keyword.put(:submit_fun, submit_fun)

      Supervisor.child_spec({RequestBatcher, opts}, id: batcher_name)
    end)
    |> Supervisor.init(strategy: :one_for_one)
  end
end
