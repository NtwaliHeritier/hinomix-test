defmodule Hinomix.ClicksTest do
  use Hinomix.DataCase

  alias Hinomix.Clicks
  alias Hinomix.Clicks.Click

  describe "clicks" do
    @valid_attrs %{
      source: "google",
      campaign_id: "camp_123",
      revenue: Decimal.new("1.50"),
      clicked_at: ~U[2024-01-01 12:00:00Z]
    }
    @invalid_attrs %{source: nil, campaign_id: nil, revenue: nil, clicked_at: nil}

    def click_fixture(attrs \\ %{}) do
      {:ok, click} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clicks.create_click()

      click
    end

    test "list_clicks/0 returns all clicks" do
      click = click_fixture()
      assert Clicks.list_clicks() == [click]
    end

    test "get_click!/1 returns the click with given id" do
      click = click_fixture()
      assert Clicks.get_click!(click.id) == click
    end

    test "create_click/1 with valid data creates a click" do
      valid_attrs = @valid_attrs

      assert {:ok, %Click{} = click} = Clicks.create_click(valid_attrs)
      assert click.source == "google"
      assert click.campaign_id == "camp_123"
      assert Decimal.equal?(click.revenue, Decimal.new("1.50"))
      assert click.clicked_at == ~U[2024-01-01 12:00:00Z]
    end

    test "create_click/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clicks.create_click(@invalid_attrs)
    end

    test "update_click/2 with valid data updates the click" do
      click = click_fixture()
      update_attrs = %{
        source: "facebook",
        campaign_id: "camp_456",
        revenue: Decimal.new("2.00"),
        clicked_at: ~U[2024-01-02 12:00:00Z]
      }

      assert {:ok, %Click{} = click} = Clicks.update_click(click, update_attrs)
      assert click.source == "facebook"
      assert click.campaign_id == "camp_456"
      assert Decimal.equal?(click.revenue, Decimal.new("2.00"))
      assert click.clicked_at == ~U[2024-01-02 12:00:00Z]
    end

    test "update_click/2 with invalid data returns error changeset" do
      click = click_fixture()
      assert {:error, %Ecto.Changeset{}} = Clicks.update_click(click, @invalid_attrs)
      assert click == Clicks.get_click!(click.id)
    end

    test "delete_click/1 deletes the click" do
      click = click_fixture()
      assert {:ok, %Click{}} = Clicks.delete_click(click)
      assert_raise Ecto.NoResultsError, fn -> Clicks.get_click!(click.id) end
    end

    test "change_click/1 returns a click changeset" do
      click = click_fixture()
      assert %Ecto.Changeset{} = Clicks.change_click(click)
    end
  end

  describe "click tracking" do
    test "record_click/1 with valid data creates a click" do
      attrs = %{
        source: "twitter",
        campaign_id: "camp_789",
        revenue: Decimal.new("3.25"),
        clicked_at: ~U[2024-01-03 15:30:00Z]
      }

      assert {:ok, %Click{} = click} = Clicks.record_click(attrs)
      assert click.source == "twitter"
      assert click.campaign_id == "camp_789"
      assert Decimal.equal?(click.revenue, Decimal.new("3.25"))
      assert click.clicked_at == ~U[2024-01-03 15:30:00Z]
    end

    test "record_click/1 with invalid data returns error changeset" do
      attrs = %{source: nil, campaign_id: nil}
      assert {:error, %Ecto.Changeset{}} = Clicks.record_click(attrs)
    end

    test "record_click/1 validates revenue is non-negative" do
      attrs = %{
        source: "google",
        campaign_id: "camp_123",
        revenue: Decimal.new("-1.00"),
        clicked_at: ~U[2024-01-01 12:00:00Z]
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Clicks.record_click(attrs)
      assert "must be greater than or equal to 0" in errors_on(changeset).revenue
    end
  end

  describe "click summaries" do
    test "get_clicks_summary/0 returns empty list when no clicks exist" do
      assert Clicks.get_clicks_summary() == []
    end

    test "get_clicks_summary/0 returns summary for single click" do
      {:ok, _click} = Clicks.record_click(%{
        source: "google",
        campaign_id: "camp_123",
        revenue: Decimal.new("1.50"),
        clicked_at: ~U[2024-01-01 12:00:00Z]
      })

      summary = Clicks.get_clicks_summary()

      assert length(summary) == 1
      assert [%{
        campaign_id: "camp_123",
        source: "google",
        total_clicks: 1,
        total_revenue: total_revenue
      }] = summary

      assert Decimal.equal?(total_revenue, Decimal.new("1.50"))
    end

    test "get_clicks_summary/0 aggregates multiple clicks for same campaign and source" do
      # Create multiple clicks for the same campaign and source
      {:ok, _click1} = Clicks.record_click(%{
        source: "google",
        campaign_id: "camp_123",
        revenue: Decimal.new("1.50"),
        clicked_at: ~U[2024-01-01 12:00:00Z]
      })

      {:ok, _click2} = Clicks.record_click(%{
        source: "google",
        campaign_id: "camp_123",
        revenue: Decimal.new("2.25"),
        clicked_at: ~U[2024-01-01 13:00:00Z]
      })

      summary = Clicks.get_clicks_summary()

      assert length(summary) == 1
      assert [%{
        campaign_id: "camp_123",
        source: "google",
        total_clicks: 2,
        total_revenue: total_revenue
      }] = summary

      assert Decimal.equal?(total_revenue, Decimal.new("3.75"))
    end

    test "get_clicks_summary/0 separates different campaigns and sources" do
      # Create clicks for different campaigns and sources
      {:ok, _click1} = Clicks.record_click(%{
        source: "google",
        campaign_id: "camp_123",
        revenue: Decimal.new("1.00"),
        clicked_at: ~U[2024-01-01 12:00:00Z]
      })

      {:ok, _click2} = Clicks.record_click(%{
        source: "facebook",
        campaign_id: "camp_123",
        revenue: Decimal.new("2.00"),
        clicked_at: ~U[2024-01-01 13:00:00Z]
      })

      {:ok, _click3} = Clicks.record_click(%{
        source: "google",
        campaign_id: "camp_456",
        revenue: Decimal.new("3.00"),
        clicked_at: ~U[2024-01-01 14:00:00Z]
      })

      summary = Clicks.get_clicks_summary()

      assert length(summary) == 3

      # Sort by campaign_id and source for consistent testing
      sorted_summary = Enum.sort_by(summary, &{&1.campaign_id, &1.source})

      assert [
        %{campaign_id: "camp_123", source: "facebook", total_clicks: 1, total_revenue: revenue1},
        %{campaign_id: "camp_123", source: "google", total_clicks: 1, total_revenue: revenue2},
        %{campaign_id: "camp_456", source: "google", total_clicks: 1, total_revenue: revenue3}
      ] = sorted_summary

      assert Decimal.equal?(revenue1, Decimal.new("2.00"))
      assert Decimal.equal?(revenue2, Decimal.new("1.00"))
      assert Decimal.equal?(revenue3, Decimal.new("3.00"))
    end

    test "get_clicks_summary/0 handles multiple campaigns and sources correctly" do
      # Create clicks for different campaign/source combinations
      {:ok, _} = Clicks.record_click(%{
        source: "google", campaign_id: "camp_1", revenue: Decimal.new("1.00"), clicked_at: ~U[2024-01-01 12:00:00Z]
      })
      {:ok, _} = Clicks.record_click(%{
        source: "facebook", campaign_id: "camp_1", revenue: Decimal.new("2.00"), clicked_at: ~U[2024-01-01 12:00:00Z]
      })
      {:ok, _} = Clicks.record_click(%{
        source: "google", campaign_id: "camp_2", revenue: Decimal.new("3.00"), clicked_at: ~U[2024-01-01 12:00:00Z]
      })

      summary = Clicks.get_clicks_summary()

      assert length(summary) == 3

      # Verify all combinations are present
      campaign_sources = Enum.map(summary, &{&1.campaign_id, &1.source}) |> Enum.sort()
      expected = [{"camp_1", "facebook"}, {"camp_1", "google"}, {"camp_2", "google"}]
      assert campaign_sources == expected
    end
  end
end
