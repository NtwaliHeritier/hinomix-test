defmodule Hinomix.Servers.ApiResponseCacheTest do
  use ExUnit.Case

  alias Hinomix.Servers.ApiResponseCache

  @name :report_server_test

  setup do
    {:ok, pid} = ApiResponseCache.start_link(name: @name)

    data = %{
      report_id: "report_1",
      source: "faceboook",
      campaign_id: "campaign_3",
      total_clicks: 23,
      total_revenue: 45.3,
      report_date: Date.utc_today() |> Date.add(-Enum.random(1..30))
    }

    {:ok, %{pid: pid, data: data}}
  end

  describe "Checks for cache functionality" do
    test "checks that the cache is up", %{pid: pid} do
      assert Process.whereis(@name) === pid
    end

    test "adds data to the cache state and retrieves it", %{data: data} do
      assert :ok === ApiResponseCache.update_state(1, data, @name)
      assert ApiResponseCache.get_state(1, @name) === data
    end

    test "stops the cache", %{pid: pid} do
      assert :ok === GenServer.stop(pid)
    end
  end
end
