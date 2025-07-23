defmodule Hinomix.Repo.Migrations.CreateReportsTable do
  use Ecto.Migration

  def change do
    create table(:reports, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :report_id, :string, null: false
      add :source, :string, null: false
      add :campaign_id, :string, null: false
      add :total_clicks, :integer, null: false
      add :total_revenue, :decimal, precision: 10, scale: 2, null: false
      add :report_date, :date, null: false
      add :processed_at, :utc_datetime

      timestamps()
    end

    # Create indexes for efficient querying
    create index(:reports, [:source])
    create index(:reports, [:campaign_id])
    create index(:reports, [:report_date])
    create index(:reports, [:source, :campaign_id])

    # Create unique constraint on report_id
    create unique_index(:reports, [:report_id])
  end
end
