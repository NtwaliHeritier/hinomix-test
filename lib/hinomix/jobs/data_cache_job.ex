# defmodule Hinomix.Jobs.DataCacheJob do
#   use Oban.Worker, queue: :data_cache, max_attempts: 3

#   alias Hinomix.ApiClient
#   alias Hinomix.Servers.ApiResponseCache
#   alias Hinomix.Utils.DataCleaner

#   require Logger

#   @impl Oban.Worker
#   def perform(%Oban.Job{args: args}) do
#     max_pages = Map.get(args, "max_pages", 7)

#     results =
#       Enum.reduce(1..max_pages, [], fn page, acc ->
#         case ApiClient.fetch_page(page) do
#           {:ok, response} ->
#             # Process each report in the page
#             processed_reports =
#               Enum.map(response["data"], fn report_data ->
#                 # Convert string keys to atoms
#                 atomized_data =
#                   for {key, value} <- report_data, into: %{} do
#                     {String.to_atom(key), value}
#                   end

#                 ApiResponseCache.update_state(page, DataCleaner.normalize(atomized_data))
#               end)

#             acc ++ processed_reports

#           {:error, reason} ->
#             Logger.error("Failed to fetch page #{page}: #{inspect(reason)}")
#             acc
#         end
#       end)

#     successful =
#       Enum.count(results, fn
#         {:ok, _} -> true
#         _ -> false
#       end)

#     Logger.info("Report ingestion completed. Processed #{successful} reports successfully.")
#   end
# end
