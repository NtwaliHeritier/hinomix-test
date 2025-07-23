defmodule Hinomix.Reports.Report do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reports" do
    field :report_id, :string
    field :source, :string
    field :campaign_id, :string
    field :total_clicks, :integer
    field :total_revenue, :decimal
    field :report_date, :date
    field :processed_at, :utc_datetime

    timestamps()
  end

  @doc """
  Changeset function for the Report schema.
  Validates that report_id, source, campaign_id, total_clicks, total_revenue, and report_date are required.
  Ensures report_id is unique to prevent duplicate reports.
  """
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:report_id, :source, :campaign_id, :total_clicks, :total_revenue, :report_date, :processed_at])
    |> validate_required([:report_id, :source, :campaign_id, :total_clicks, :total_revenue, :report_date])
    |> validate_number(:total_clicks, greater_than_or_equal_to: 0)
    |> validate_number(:total_revenue, greater_than_or_equal_to: 0)
    |> unique_constraint(:report_id)
  end
end
