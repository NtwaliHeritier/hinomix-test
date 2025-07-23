defmodule Hinomix.ApiClient do
  @moduledoc """
  Client for interacting with the third-party reporting API.
  Uses Tesla for HTTP requests with configured timeouts.
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:4000/third-party-api/v1"
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Timeout, timeout: :infinity

  @per_page 10

  def fetch_reports(opts \\ []) do
    max_pages = Keyword.get(opts, :max_pages, 10)

    Enum.reduce(1..max_pages, [], fn page, acc ->
      case fetch_page(page, @per_page) do
        {:ok, response} ->
          acc ++ response["data"]

        {:error, reason} ->
          IO.puts("Failed to fetch page #{page}: #{inspect(reason)}")
          acc
      end
    end)
  end

  def fetch_page(page, per_page \\ @per_page) do
    case get("/reports", query: [page: page, per_page: per_page]) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status}} ->
        {:error, {:http_error, status}}

      {:error, :timeout} ->
        {:error, :timeout}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
