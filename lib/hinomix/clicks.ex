defmodule Hinomix.Clicks do
  @moduledoc """
  The Clicks context.
  Provides functions for working with click data and generating summaries.
  """

  import Ecto.Query, warn: false
  alias Hinomix.Repo
  alias Hinomix.Clicks.Click

  @doc """
  Returns the list of clicks.

  ## Examples

      iex> list_clicks()
      [%Click{}, ...]

  """
  def list_clicks do
    Repo.all(Click)
  end

  @doc """
  Gets a single click.

  Raises `Ecto.NoResultsError` if the Click does not exist.

  ## Examples

      iex> get_click!(123)
      %Click{}

      iex> get_click!(456)
      ** (Ecto.NoResultsError)

  """
  def get_click!(id), do: Repo.get!(Click, id)

  @doc """
  Creates a click.

  ## Examples

      iex> create_click(%{field: value})
      {:ok, %Click{}}

      iex> create_click(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_click(attrs \\ %{}) do
    %Click{}
    |> Click.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a click.

  ## Examples

      iex> update_click(click, %{field: new_value})
      {:ok, %Click{}}

      iex> update_click(click, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_click(%Click{} = click, attrs) do
    click
    |> Click.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a click.

  ## Examples

      iex> delete_click(click)
      {:ok, %Click{}}

      iex> delete_click(click)
      {:error, %Ecto.Changeset{}}

  """
  def delete_click(%Click{} = click) do
    Repo.delete(click)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking click changes.

  ## Examples

      iex> change_click(click)
      %Ecto.Changeset{data: %Click{}}

  """
  def change_click(%Click{} = click, attrs \\ %{}) do
    Click.changeset(click, attrs)
  end

  @doc """
  Records a click with the provided attributes.
  This is the main function for tracking click events.

  ## Examples

      iex> record_click(%{source: "google", campaign_id: "camp_123", revenue: Decimal.new("1.50"), clicked_at: DateTime.utc_now()})
      {:ok, %Click{}}

      iex> record_click(%{source: nil})
      {:error, %Ecto.Changeset{}}

  """
  def record_click(attrs) do
    %Click{}
    |> Click.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a summary of clicks grouped by campaign and source.

  ## Examples

      iex> get_clicks_summary()
      [
        %{
          campaign_id: "camp_123",
          source: "google",
          total_clicks: 10,
          total_revenue: Decimal.new("15.00")
        }
      ]

  """
  def get_clicks_summary(_opts \\ []) do
    # Get all unique campaign_id and source combinations
    campaigns_and_sources =
      from(c in Click,
        select: {c.campaign_id, c.source},
        distinct: true
      )
      |> Repo.all()

    # Generate summary for each campaign/source combination
    Enum.map(campaigns_and_sources, fn {campaign_id, source} ->
      # Fetch clicks for this combination
      clicks =
        from(c in Click,
          where: c.campaign_id == ^campaign_id and c.source == ^source,
          select: c
        )
        |> Repo.all()

      # Calculate totals in application code instead of database
      total_clicks = length(clicks)
      total_revenue =
        clicks
        |> Enum.reduce(Decimal.new(0), fn click, acc ->
          Decimal.add(acc, click.revenue)
        end)

      %{
        campaign_id: campaign_id,
        source: source,
        total_clicks: total_clicks,
        total_revenue: total_revenue
      }
    end)
    |> Enum.sort_by(& &1.campaign_id)
  end

  @doc """
  Gets a summary of clicks for a specific source and campaign.
  Used by ReportProcessor to compare with report data.
  """
  def get_summary_for_campaign(source, campaign_id) do
    clicks =
      from(c in Click,
        where: c.source == ^source and c.campaign_id == ^campaign_id,
        select: c
      )
      |> Repo.all()

    total_clicks = length(clicks)
    total_revenue =
      clicks
      |> Enum.reduce(Decimal.new(0), fn click, acc ->
        Decimal.add(acc, click.revenue || Decimal.new(0))
      end)

    %{
      source: source,
      campaign_id: campaign_id,
      total_clicks: total_clicks,
      total_revenue: total_revenue
    }
  end
end
