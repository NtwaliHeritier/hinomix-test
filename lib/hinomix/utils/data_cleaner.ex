defmodule Hinomix.Utils.DataCleaner do
  def normalize(params) do
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
