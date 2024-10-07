defmodule Plausible.IngestRepo.Migrations.AddImportedCustomEvents do
  use Ecto.Migration

  def change do
    # NOTE: Using another table for determining cluster presence
    on_cluster = Plausible.MigrationUtils.on_cluster_statement("imported_pages")

    settings =
      if Plausible.IngestRepo.clustered_table?("imported_pages") do
        """
        ORDER BY (site_id, import_id, date, name)
        """
      else
        """
        ENGINE = MergeTree()
        ORDER BY (site_id, import_id, date, name)
        SETTINGS replicated_deduplication_window = 0
        """
      end

    execute """
            CREATE TABLE IF NOT EXISTS imported_custom_events #{on_cluster}
                (
                `site_id` UInt64,
                `import_id` UInt64,
                `date` Date,
                `name` String CODEC(ZSTD(3)),
                `link_url` String CODEC(ZSTD(3)),
                `path` String CODEC(ZSTD(3)),
                `visitors` UInt64,
                `events` UInt64
            )
            #{settings}
            """,
            """
            DROP TABLE IF EXISTS imported_custom_events #{on_cluster} SYNC
            """
  end
end
