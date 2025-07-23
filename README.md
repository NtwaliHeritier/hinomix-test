# Hinomix Analytics System

## Overview

Hinomix is an Elixir application that processes click tracking data and generates reports from external APIs. The system ingests third-party report data, tracks clicks, and provides analytics summaries through CLI commands.

## System Architecture

- **Phoenix Framework**: Provides the application infrastructure
- **Ecto**: Database layer for PostgreSQL
- **Oban**: Background job processing for report ingestion
- **Click Tracking**: Records and aggregates click events by source and campaign
- **Report Processing**: Ingests and processes external report data

## Prerequisites

- Elixir 1.15 or later
- PostgreSQL 14 or later
- Node.js (for assets)

## Setup Instructions

1. **Install dependencies**
   ```bash
   mix deps.get
   ```

2. **Create and migrate the database**
   ```bash
   mix ecto.setup
   ```

3. **Start the application**
   ```bash
   iex -S mix
   ```

This will start an interactive Elixir shell with the application running.

## Running Background Jobs

The system uses Oban for background job processing. Jobs are automatically started when the application runs.

To manually trigger report ingestion:

```elixir
# In iex -S mix
{:ok, job} = Hinomix.Jobs.ReportIngestionJob.new(%{"max_pages" => 5}) |> Oban.insert()
```

## Available Mix Tasks

View click summaries:
```bash
mix hinomix.clicks
```

View processed reports:
```bash
mix hinomix.reports
```

Check for discrepancies between clicks and reports:
```bash
mix hinomix.discrepancies [--threshold 10]
```

## Seed Data

To generate sample click data for testing:

```bash
mix run priv/repo/seeds.exs
```

## Key Components

### Click Tracking
- Stores individual click events with source, campaign, and revenue data
- Provides aggregated summaries by campaign and source

### Report Processing
- Fetches paginated report data from external API
- Processes and stores report summaries
- Compares report data with actual click data

### Background Jobs
- `ReportIngestionJob`: Fetches and processes reports from the API
- `DiscrepancyCheckJob`: Compares click data with report data and logs discrepancies

## Database Schema

### Clicks Table
- `id`: UUID primary key
- `source`: Traffic source (e.g., "google", "facebook")
- `campaign_id`: Campaign identifier
- `revenue`: Revenue amount
- `clicked_at`: Timestamp of the click

### Reports Table
- `id`: UUID primary key
- `report_id`: External report identifier
- `source`: Traffic source
- `campaign_id`: Campaign identifier
- `total_clicks`: Number of clicks reported
- `total_revenue`: Revenue reported
- `report_date`: Date of the report
- `processed_at`: When the report was processed

## API Integration

The system integrates with a mock third-party API that provides paginated report data. The API client handles:
- Pagination through multiple pages of results
- Processing each report through the report processor
- Error handling and retries via Oban

## Task: System Analysis

You've been brought in to investigate issues with this analytics system. The team has reported several problems:

1. **"The report ingestion job takes too long"** - They've asked for suggestions to improve performance
2. **"The numbers don't add up"** - There are discrepancies between reports and actual data
3. **"Sometimes the job fails"** - The system isn't as reliable as it should be
4. **"We aren't technical enough to see the reports" - Some team members would like a visual report or UI

Your task is to investigate these issues and identify:
- Root causes of the problems
- Performance bottlenecks
- Data consistency issues
- Suggestions for improvements

### Getting Started

1. **Generate initial data and run the system:**
   ```bash
   # Reset database and seed initial data
   mix ecto.reset
   
   # This creates click data and runs an initial report ingestion
   ```

2. **Examine the current state:**
   ```bash
   # View click summaries
   mix hinomix.clicks
   
   # View processed reports
   mix hinomix.reports
   
   # Check for discrepancies
   mix hinomix.discrepancies
   ```

3. **Run additional report ingestions:**
   ```elixir
   # In iex -S mix
   
   # Run another ingestion job
   {:ok, job} = %{} |> Hinomix.Jobs.ReportIngestionJob.new() |> Oban.insert()
   
   # Check the reports again
   # Exit iex with Ctrl+C twice, then:
   mix hinomix.reports
   ```

4. **Test with different scenarios:**
   ```elixir
   # Try processing more pages
   {:ok, job} = %{"max_pages" => 7} |> Hinomix.Jobs.ReportIngestionJob.new() |> Oban.insert()
   
   # Monitor job execution
   Oban.Job |> Repo.all() |> Enum.map(& {&1.state, &1.worker})
   ```

### Areas to Investigate

1. **Data Integrity**: 
   - Why do report totals differ from actual click data?
   - What happens when you run the same ingestion job multiple times?
   - Are reports being processed correctly?

2. **Performance**:
   - How long does it take to process all pages?
   - Enable debug logging (`config :logger, level: :debug` in `config/dev.exs`) and run `mix hinomix.clicks`
   - What do you notice about the database queries?

3. **Reliability**:
   - What happens when processing many pages?
   - Check job failures: `Oban.Job |> where([j], j.state == "discarded") |> Repo.all()`
   - Why might some pages fail to process?

4. **Data Quality**:
   - Examine the actual data being returned by the API
   - Are there any inconsistencies in the data format?

### Useful Commands

```elixir
# Check processing history
Hinomix.Reports.Report 
|> Repo.all() 
|> Enum.map(& {&1.report_id, &1.total_revenue, &1.processed_at})

# Examine job errors
Oban.Job 
|> where([j], not is_nil(j.errors)) 
|> Repo.all() 
|> Enum.map(& &1.errors)

# Time operations
:timer.tc(fn -> Hinomix.Clicks.get_clicks_summary() end)

# Direct API testing
Hinomix.ApiClient.fetch_page(1)  # Try different page numbers
```

## Monitoring

The system logs important events including:
- Report ingestion progress
- Processing errors
- Discrepancy alerts when click data doesn't match report data

Check application logs for detailed information about system operations.

## Testing

Run the test suite:
```bash
mix test
```

## Using AI Assistants

You're welcome to use AI assistants (ChatGPT, Claude, Copilot, etc.) during this assessment. If you do:

1. Please save your AI conversations in the `.ai/` directory
2. Include both your prompts and the AI's responses
3. Add a brief reflection on whether the AI helped or hindered your process

We're interested in how developers effectively use modern tools, so please be transparent about your process. See `AGENTS.md` for more guidelines.

## Notes

- The system includes a mock third-party API endpoint (`/third-party-api/v1/reports`) that simulates external service behavior
- The `ThirdPartyApiController` should NOT be modified as it represents an external service
- The `ApiClient` uses Tesla with a 5-second timeout for HTTP requests
- Focus on how the system handles and processes the data it receives
- Consider both correctness and performance in your analysis

## Important Note

The `ApiClient` module simulates an external third-party API. Do not modify this file as it represents a service outside your control.
