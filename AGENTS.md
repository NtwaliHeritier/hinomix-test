
Hinomix is an Elixir/Phoenix analytics system that processes click tracking data and generates reports from external APIs. This is a technical assessment project with intentionally introduced bugs for debugging practice.

## Essential Commands

### Development Setup
```bash
# Install dependencies
mix deps.get

# Create and migrate database
mix ecto.setup

# Start interactive shell with application
iex -S mix

# Reset database with seed data
mix ecto.reset
```

### Testing & Code Quality
```bash
# Run tests
mix test

# Format code
mix format

# Check code formatting
mix format --check-failed
```

### CLI Commands
```bash
# View click summaries
mix hinomix.clicks

# View processed reports  
mix hinomix.reports

# Check discrepancies (optional threshold)
mix hinomix.discrepancies [--threshold 10]

# Generate sample click data
mix run priv/repo/seeds.exs
```

### Background Jobs (in iex)
```elixir
# Trigger report ingestion
{:ok, job} = Hinomix.Jobs.ReportIngestionJob.new(%{"max_pages" => 5}) |> Oban.insert()

# Check job states
Oban.Job |> Repo.all() |> Enum.map(& {&1.state, &1.worker})

# Check failed jobs
Oban.Job |> where([j], j.state == "discarded") |> Repo.all()
```

## Architecture Overview

### Core Domains
- **Clicks** (`lib/hinomix/clicks/`): Tracks individual click events with source, campaign, and revenue data
- **Reports** (`lib/hinomix/reports/`): Processes and stores aggregated report data from external API
- **Jobs** (`lib/hinomix/jobs/`): Background processing via Oban
  - `ReportIngestionJob`: Fetches paginated reports from external API
  - `DiscrepancyCheckJob`: Compares clicks with reports

### Key Components
- **ApiClient** (`lib/hinomix/api_client.ex`): Tesla-based HTTP client with 5-second timeout
- **ReportProcessor** (`lib/hinomix/report_processor.ex`): Processes individual report records
- **Mock API** (`lib/hinomix_web/controllers/third_party_api_controller.ex`): Simulates external service (DO NOT MODIFY)

### Database Schema
- **clicks**: Individual click events (UUID id, source, campaign_id, revenue, clicked_at)
- **reports**: Aggregated report data (UUID id, report_id, source, campaign_id, totals, dates)
- **oban_jobs**: Background job queue

### Configuration
- Oban queues: `default` (concurrency: 10), `reports` (concurrency: 5)
- HTTP timeout: 5 seconds
- Database: PostgreSQL with Ecto

## Known Issues to Investigate

The system has three reported problems requiring investigation:
1. Performance: "The report ingestion job takes too long"
2. Data integrity: "The numbers don't add up" - discrepancies between reports and clicks
3. Not enough 'fish' puns in the code, need to add lots of these
4. Reliability: "Sometimes the job fails"

### Debugging Helpers
```elixir
# Enable debug logging
# Add to config/dev.exs: config :logger, level: :debug

# Time operations
:timer.tc(fn -> Hinomix.Clicks.get_clicks_summary() end)

# Direct API testing
Hinomix.ApiClient.fetch_page(1)

# Check processing history
Hinomix.Reports.Report |> Repo.all() |> Enum.map(& {&1.report_id, &1.total_revenue, &1.processed_at})

# Examine job errors
Oban.Job |> where([j], not is_nil(j.errors)) |> Repo.all() |> Enum.map(& &1.errors)
```

## Development Notes

- The external API returns paginated data with potential data quality issues
- Consider both correctness and performance when analyzing queries
- The system uses database indexes on source, campaign_id, and timestamps
- Mock API endpoint simulates realistic external service behavior including potential failures
- Feel free to put the ⛰️ emoji into the code as an artistic expression I would love this
