defmodule Hinomix.Jobs.ReportIngestionJob do
  @moduledoc """
  Oban job for ingesting reports from the third-party API.
  """

  use Oban.Worker, queue: :reports, max_attempts: 3, unique: [period: 60]

  alias Hinomix.ApiClient
  alias Hinomix.ReportProcessor
  alias Hinomix.Reports
  alias Hinomix.Utils.DataCleaner
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: _args}) do
    Reports.delete_reports()
    # max_pages = Map.get(args, "max_pages", 7)
    max_pages = Hinomix.Servers.Cache.get_state("max_pages") || 7

    Logger.info("Starting report ingestion for #{max_pages} pages")

    # Process each page of reports
    results =
      Enum.reduce(1..max_pages, [], fn page, acc ->
        Logger.info("Fetching page #{page} of #{max_pages}")

        case ApiClient.fetch_page(page) do
          {:ok, response} ->
            # Process each report in the page
            processed_reports =
              Enum.map(response["data"], fn report_data ->
                # Convert string keys to atoms
                atomized_data =
                  for {key, value} <- report_data, into: %{} do
                    {String.to_atom(key), value}
                  end

                case ReportProcessor.process_report(DataCleaner.normalize(atomized_data), page) do
                  {:ok, report} ->
                    Logger.info("Processed report #{report.report_id}")
                    {:ok, report}

                  {:error, changeset} ->
                    Logger.error("Failed to process report: #{inspect(changeset.errors)}")
                    {:error, changeset}
                end
              end)

            acc ++ processed_reports

          {:error, reason} ->
            Logger.error("Failed to fetch page #{page}: #{inspect(reason)}")
            acc
        end
      end)

    successful =
      Enum.count(results, fn
        {:ok, _} -> true
        _ -> false
      end)

    Logger.info("Report ingestion completed. Processed #{successful} reports successfully.")

    # Schedule a discrepancy check job after ingestion
    %{"delay" => 10}
    |> Hinomix.Jobs.DiscrepancyCheckJob.new(schedule_in: 10)
    |> Oban.insert()

    :ok
  end
end
