defmodule Mix.Tasks.Hinomix.Discrepancies do
  @moduledoc """
  Mix task for viewing discrepancies between clicks and reports.
  
  Usage:
    mix hinomix.discrepancies [--threshold 10]
  """

  use Mix.Task
  
  alias Hinomix.ReportProcessor

  @shortdoc "Display discrepancies between clicks and reports"
  def run(args) do
    Mix.Task.run("app.start")
    
    {opts, _, _} = OptionParser.parse(args, switches: [threshold: :integer])
    threshold = Keyword.get(opts, :threshold, 10)
    
    IO.puts("\n=== Discrepancy Report (Threshold: #{threshold}%) ===\n")
    
    discrepancies = ReportProcessor.detect_discrepancies(threshold)
    
    if Enum.empty?(discrepancies) do
      IO.puts("No discrepancies found above #{threshold}% threshold.")
    else
      IO.puts("Found #{length(discrepancies)} discrepancies:\n")
      
      Enum.each(discrepancies, fn disc ->
        click_diff_pct = if disc.actual_clicks > 0 do
          Float.round(abs(disc.click_discrepancy) / disc.actual_clicks * 100, 2)
        else
          0.0
        end
        
        revenue_diff_pct = if Decimal.compare(disc.actual_revenue, Decimal.new(0)) == :gt do
          disc.revenue_discrepancy
          |> Decimal.abs()
          |> Decimal.div(disc.actual_revenue)
          |> Decimal.mult(Decimal.new(100))
          |> Decimal.to_float()
          |> Float.round(2)
        else
          0.0
        end
        
        IO.puts("Source: #{disc.source}, Campaign: #{disc.campaign_id}")
        IO.puts("  Clicks  - Report: #{disc.report_clicks}, Actual: #{disc.actual_clicks}, Diff: #{disc.click_discrepancy} (#{click_diff_pct}%)")
        IO.puts("  Revenue - Report: $#{disc.report_revenue}, Actual: $#{disc.actual_revenue}, Diff: $#{disc.revenue_discrepancy} (#{revenue_diff_pct}%)")
        IO.puts("")
      end)
    end
    
    IO.puts("")
  end
end