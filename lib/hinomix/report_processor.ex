defmodule Hinomix.ReportProcessor do
  @moduledoc """
  Context module for processing and storing report data.
  """

  alias Hinomix.Repo
  alias Hinomix.Reports.Report
  alias Hinomix.Clicks
  require Logger

  def process_report(report_data) do
    # Check if report already exists by source and campaign

    case Repo.get_by(Report,
           source: report_data.source,
           campaign_id: report_data.campaign_id
         ) do
      nil ->
        # Create new report
        %Report{}
        |> Report.changeset(Map.put(report_data, :processed_at, DateTime.utc_now()))
        |> Repo.insert()

      existing_report ->
        # Update existing report with new data
        updated_revenue =
          Decimal.add(
            existing_report.total_revenue || Decimal.new(0),
            report_data.total_revenue || Decimal.new(0)
          )

        updated_clicks = (existing_report.total_clicks || 0) + (report_data.total_clicks || 0)

        existing_report
        |> Report.changeset(%{
          total_revenue: updated_revenue,
          total_clicks: updated_clicks,
          processed_at: DateTime.utc_now()
        })
        |> Repo.update()
    end
  end

  def compare_with_clicks(report) do
    # Get actual clicks for the same source and campaign
    click_summary = Clicks.get_summary_for_campaign(report.source, report.campaign_id)

    %{
      report_id: report.id,
      source: report.source,
      campaign_id: report.campaign_id,
      report_clicks: report.total_clicks,
      actual_clicks: click_summary.total_clicks,
      report_revenue: report.total_revenue,
      actual_revenue: click_summary.total_revenue,
      click_discrepancy: report.total_clicks - click_summary.total_clicks,
      revenue_discrepancy: Decimal.sub(report.total_revenue, click_summary.total_revenue)
    }
  end

  def detect_discrepancies(threshold_percentage \\ 10) do
    reports = Repo.all(Report)

    discrepancies =
      Enum.map(reports, fn report ->
        comparison = compare_with_clicks(report)

        # Calculate discrepancy percentage
        click_discrepancy_pct =
          if comparison.actual_clicks > 0 do
            abs(comparison.click_discrepancy) / comparison.actual_clicks * 100
          else
            0
          end

        revenue_discrepancy_pct =
          if Decimal.compare(comparison.actual_revenue, Decimal.new(0)) == :gt do
            comparison.revenue_discrepancy
            |> Decimal.abs()
            |> Decimal.div(comparison.actual_revenue)
            |> Decimal.mult(Decimal.new(100))
            |> Decimal.to_float()
          else
            0
          end

        if click_discrepancy_pct > threshold_percentage or
             revenue_discrepancy_pct > threshold_percentage do
          Logger.warning(
            "Discrepancy detected for #{report.source} - #{report.campaign_id}: " <>
              "Clicks: #{comparison.click_discrepancy} (#{Float.round(click_discrepancy_pct, 2)}%), " <>
              "Revenue: #{comparison.revenue_discrepancy} (#{Float.round(revenue_discrepancy_pct, 2)}%)"
          )

          Map.put(comparison, :alert, true)
        else
          Map.put(comparison, :alert, false)
        end
      end)

    Enum.filter(discrepancies, & &1.alert)
  end

  def list_reports do
    Repo.all(Report)
  end

  def get_report!(id) do
    Repo.get!(Report, id)
  end
end
