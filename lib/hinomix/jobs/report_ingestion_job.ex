defmodule Hinomix.Jobs.ReportIngestionJob do
  @moduledoc """
  Oban job for ingesting reports from the third-party API.
  """

  use Oban.Worker, queue: :reports, max_attempts: 3

  alias Hinomix.ApiClient
  alias Hinomix.ReportProcessor
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    max_pages = Map.get(args, "max_pages", 7)

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

                case ReportProcessor.process_report(normalize_params(atomized_data)) do
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

  defp normalize_params(params) do
    params
    |> normalize_source()
    |> normalize_campaign_id()
    |> normalize_total_clicks()
    |> normalize_total_revenue()
  end

  defp normalize_source(%{source: source} = params) do
    source = source |> String.trim() |> String.downcase()
    Map.put(params, :source, source)
  end

  defp normalize_campaign_id(%{campaign_id: campaign_id} = params) do
    campaign_id = campaign_id |> String.trim() |> String.downcase()
    Map.put(params, :campaign_id, campaign_id)
  end

  defp normalize_total_clicks(%{total_clicks: nil} = params),
    do: Map.put(params, :total_clicks, 0)

  defp normalize_total_clicks(%{total_clicks: total_clicks} = params)
       when is_binary(total_clicks),
       do: Map.put(params, :total_clicks, String.to_integer(total_clicks))

  defp normalize_total_clicks(params), do: params

  defp normalize_total_revenue(%{total_revenue: total_revenue} = params)
       when is_binary(total_revenue) do
    total_revenue = Decimal.new(Regex.replace(~r/^[^\d]+/, total_revenue, ""))
    Map.put(params, :total_revenue, total_revenue)
  end

  defp normalize_total_revenue(params), do: params
end
