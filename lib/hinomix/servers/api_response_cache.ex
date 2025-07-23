defmodule Hinomix.Servers.ApiResponseCache do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: :report_server)
  end

  def init(state) do
    {:ok, state}
  end

  def update_state(page_number, data) do
    GenServer.cast(:report_server, {:update, %{page_number: page_number, data: data}})
  end

  def get_state(page_number) do
    GenServer.call(:report_server, {:get, page_number})
  end

  def handle_cast({:update, %{page_number: page_number, data: data}}, state) do
    state = Map.put(state, "page_#{page_number}", data)
    {:noreply, state}
  end

  def handle_call({:get, page_number}, _, state) do
    {:reply, Map.get(state, "page_#{page_number}"), state}
  end
end
