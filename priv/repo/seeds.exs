# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias Hinomix.Clicks
alias Hinomix.Repo

# Clear existing data
Repo.delete_all(Hinomix.Clicks.Click)
Repo.delete_all(Hinomix.Reports.Report)

# Seed click data
sources = ["google", "facebook", "twitter"]
campaigns = ["campaign_1", "campaign_2", "campaign_3", "campaign_4", "campaign_5"]

IO.puts("Seeding click data...")

# Generate clicks for the past 30 days
for days_ago <- 0..29 do
  date = Date.utc_today() |> Date.add(-days_ago)
  
  # Generate 50-200 clicks per day
  num_clicks = Enum.random(50..200)
  
  for _ <- 1..num_clicks do
    source = Enum.random(sources)
    campaign = Enum.random(campaigns)
    
    # Revenue between $0.50 and $5.00
    revenue = Decimal.div(Decimal.new(Enum.random(50..500)), Decimal.new(100))
    
    # Random time during the day
    hour = Enum.random(0..23)
    minute = Enum.random(0..59)
    second = Enum.random(0..59)
    
    clicked_at = DateTime.new!(date, Time.new!(hour, minute, second))
    
    Clicks.record_click(%{
      source: source,
      campaign_id: campaign,
      revenue: revenue,
      clicked_at: clicked_at
    })
  end
end

IO.puts("Seeded #{Repo.aggregate(Hinomix.Clicks.Click, :count)} clicks")

# Run initial report ingestion
IO.puts("\nTriggering initial report ingestion...")
{:ok, _job} = %{} 
|> Hinomix.Jobs.ReportIngestionJob.new() 
|> Oban.insert()

IO.puts("Report ingestion job queued. Run 'mix hinomix.reports' to view reports after processing.")
IO.puts("\nSeed data generation complete!")