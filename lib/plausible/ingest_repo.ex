defmodule Plausible.IngestRepo do
  @moduledoc """
  Write-centric Clickhouse access interface
  """

  use Ecto.Repo,
    otp_app: :plausible,
    adapter: Ecto.Adapters.ClickHouse

  defmacro __using__(_) do
    quote do
      alias Plausible.IngestRepo
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  def clustered_table?(table) do
    case query("SELECT 1 FROM system.replicas WHERE table = '#{table}'") do
      {:ok, %{rows: []}} -> false
      {:ok, _} -> true
    end
  end
end
