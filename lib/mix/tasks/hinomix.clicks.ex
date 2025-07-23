defmodule Mix.Tasks.Hinomix.Clicks do
  @moduledoc """
  Mix task for viewing click summaries.
  
  Usage:
    mix hinomix.clicks
  """

  use Mix.Task
  
  alias Hinomix.Clicks

  @shortdoc "Display click summaries"
  def run(_args) do
    Mix.Task.run("app.start")
    
    IO.puts("\n=== Click Summary ===\n")
    
    summaries = Clicks.get_clicks_summary()
    
    if Enum.empty?(summaries) do
      IO.puts("No clicks found.")
    else
      IO.puts("#{String.pad_trailing("Source", 15)} #{String.pad_trailing("Campaign", 15)} #{String.pad_trailing("Clicks", 10)} Revenue")
      IO.puts(String.duplicate("-", 60))
      
      Enum.each(summaries, fn summary ->
        IO.puts("#{String.pad_trailing(summary.source, 15)} #{String.pad_trailing(summary.campaign_id, 15)} #{String.pad_trailing(to_string(summary.total_clicks), 10)} $#{summary.total_revenue}")
      end)
      
      total_clicks = Enum.reduce(summaries, 0, &(&1.total_clicks + &2))
      total_revenue = Enum.reduce(summaries, Decimal.new(0), &Decimal.add(&1.total_revenue, &2))
      
      IO.puts(String.duplicate("-", 60))
      IO.puts("#{String.pad_trailing("TOTAL", 31)} #{String.pad_trailing(to_string(total_clicks), 10)} $#{total_revenue}")
    end
    
    IO.puts("")
  end
end