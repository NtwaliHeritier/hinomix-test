defmodule Hinomix.Repo.Migrations.CreateClicksTable do
  use Ecto.Migration

  def change do
    create table(:clicks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :source, :string, null: false
      add :campaign_id, :string, null: false
      add :revenue, :decimal, precision: 10, scale: 2, null: false
      add :clicked_at, :utc_datetime, null: false

      timestamps()
    end

    # Create indexes for efficient querying
    create index(:clicks, [:source])
    create index(:clicks, [:campaign_id])
    create index(:clicks, [:clicked_at])
    create index(:clicks, [:source, :campaign_id])
  end
end
