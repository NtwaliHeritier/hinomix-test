defmodule Mix.Tasks.Hinomix.Reports do
  @moduledoc """
  Mix task for viewing reports.
  
  Usage:
    mix hinomix.reports
  """

  use Mix.Task
  
  alias Hinomix.ReportProcessor

  @shortdoc "Display reports"
  def run(_args) do
    Mix.Task.run("app.start")
    
    IO.puts("\n=== Reports Summary ===\n")
    
    reports = ReportProcessor.list_reports()
    
    if Enum.empty?(reports) do
      IO.puts("No reports found.")
    else
      IO.puts("#{String.pad_trailing("Report ID", 15)} #{String.pad_trailing("Source", 10)} #{String.pad_trailing("Campaign", 15)} #{String.pad_trailing("Clicks", 10)} #{String.pad_trailing("Revenue", 12)} Processed At")
      IO.puts(String.duplicate("-", 90))
      
      Enum.each(reports, fn report ->
        processed_at = if report.processed_at do
          Calendar.strftime(report.processed_at, "%Y-%m-%d %H:%M:%S")
        else
          "Not processed"
        end
        
        IO.puts("#{String.pad_trailing(report.report_id, 15)} #{String.pad_trailing(report.source, 10)} #{String.pad_trailing(report.campaign_id, 15)} #{String.pad_trailing(to_string(report.total_clicks), 10)} #{String.pad_trailing("$#{report.total_revenue}", 12)} #{processed_at}")
      end)
      
      total_clicks = Enum.reduce(reports, 0, &(&1.total_clicks + &2))
      total_revenue = Enum.reduce(reports, Decimal.new(0), &Decimal.add(&1.total_revenue, &2))
      
      IO.puts(String.duplicate("-", 90))
      IO.puts("#{String.pad_trailing("TOTAL", 41)} #{String.pad_trailing(to_string(total_clicks), 10)} $#{total_revenue}")
    end
    
    IO.puts("")
  end
end