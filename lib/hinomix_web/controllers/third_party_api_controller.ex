defmodule HinomixWeb.ThirdPartyApiController do
  @moduledoc """
  IMPORTANT: This controller simulates an external third-party API service.
  DO NOT MODIFY THIS FILE - In a real scenario, this would be hosted on external servers
  and you would have no control over its behavior, performance, or data quality.
  
  This endpoint is intentionally designed to exhibit real-world API issues:
  - Variable response times
  - Timeout issues
  - Data quality problems
  """
  
  use HinomixWeb, :controller

  def reports(conn, params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    
    # Simulate increasing latency based on page number
    # This mimics APIs that slow down with deeper pagination
    delay = page * 1000
    Process.sleep(delay)
    
    # Generate the response data
    data = generate_mock_reports(page, per_page)
    
    json(conn, %{
      data: data,
      meta: %{
        current_page: page,
        total_pages: 7,
        total_items: 70
      }
    })
  end

  defp generate_mock_reports(page, per_page) do
    start_index = (page - 1) * per_page
    
    Enum.map(1..per_page, fn index ->
      report_index = start_index + index
      
      # Data quality degrades on later pages (simulating real-world issues)
      source = if page >= 7 do
        case Enum.random(1..10) do
          1 -> "Google"
          2 -> "facebook "
          3 -> "twiiter"
          4 -> "fb"
          _ -> Enum.random(["google", "facebook", "twitter"])
        end
      else
        Enum.random(["google", "facebook", "twitter"])
      end
      
      campaign_id = if page >= 7 do
        case Enum.random(1..8) do
          1 -> "Campaign_#{Enum.random(1..5)}"
          2 -> "campaign#{Enum.random(1..5)}"
          3 -> " campaign_#{Enum.random(1..5)}"
          _ -> "campaign_#{Enum.random(1..5)}"
        end
      else
        "campaign_#{Enum.random(1..5)}"
      end
      
      # Revenue formatting issues only on page 7
      total_revenue = if page == 7 do
        case Enum.random(1..3) do
          1 -> 
            "$#{Enum.random(10..100)}.#{Enum.random(10..99)}"
          2 ->
            "#{Enum.random(1..9)},#{Enum.random(100..999)}.#{Enum.random(10..99)}"
          _ ->
            Decimal.div(Decimal.new(Enum.random(1000..10000)), Decimal.new(100))
        end
      else
        Decimal.div(Decimal.new(Enum.random(1000..10000)), Decimal.new(100))
      end
      
      total_clicks = if page >= 7 do
        case Enum.random(1..15) do
          1 -> nil
          2 -> "#{Enum.random(100..1000)}"
          _ -> Enum.random(100..1000)
        end
      else
        Enum.random(100..1000)
      end
      
      %{
        report_id: "report_#{report_index}",
        source: source,
        campaign_id: campaign_id,
        total_clicks: total_clicks,
        total_revenue: total_revenue,
        report_date: Date.utc_today() |> Date.add(-Enum.random(1..30))
      }
    end)
  end
end