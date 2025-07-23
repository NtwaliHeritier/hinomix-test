defmodule Hinomix.Jobs.DiscrepancyCheckJob do
  @moduledoc """
  Oban job for checking discrepancies between click data and report data.
  Logs alerts when significant discrepancies are detected.
  """

  use Oban.Worker, queue: :default, max_attempts: 3

  alias Hinomix.ReportProcessor
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    threshold = Map.get(args, "threshold_percentage", 10)
    
    Logger.info("Starting discrepancy check with threshold: #{threshold}%")
    
    discrepancies = ReportProcessor.detect_discrepancies(threshold)
    
    if Enum.empty?(discrepancies) do
      Logger.info("No discrepancies detected above threshold")
    else
      Logger.warning("Found #{length(discrepancies)} discrepancies!")
      
      Enum.each(discrepancies, fn discrepancy ->
        Logger.warning("""
        Discrepancy Alert:
        - Source: #{discrepancy.source}
        - Campaign: #{discrepancy.campaign_id}
        - Click Discrepancy: #{discrepancy.click_discrepancy}
        - Revenue Discrepancy: #{discrepancy.revenue_discrepancy}
        - Report Clicks: #{discrepancy.report_clicks}
        - Actual Clicks: #{discrepancy.actual_clicks}
        - Report Revenue: #{discrepancy.report_revenue}
        - Actual Revenue: #{discrepancy.actual_revenue}
        """)
      end)
    end
    
    :ok
  end
end