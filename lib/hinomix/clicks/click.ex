defmodule Hinomix.Clicks.Click do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clicks" do
    field :source, :string
    field :campaign_id, :string
    field :revenue, :decimal
    field :clicked_at, :utc_datetime

    timestamps()
  end

  @doc """
  Changeset function for the Click schema.
  Validates that source, campaign_id, revenue, and clicked_at are required.
  """
  def changeset(click, attrs) do
    click
    |> cast(attrs, [:source, :campaign_id, :revenue, :clicked_at])
    |> validate_required([:source, :campaign_id, :revenue, :clicked_at])
    |> validate_number(:revenue, greater_than_or_equal_to: 0)
  end
end
