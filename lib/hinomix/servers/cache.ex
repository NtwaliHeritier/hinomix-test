defmodule Hinomix.Servers.Cache do
  use GenServer

  @name :report_server

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, @name)
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  def init(state) do
    {:ok, state}
  end

  def update_state(page_number, data, name \\ @name) do
    GenServer.cast(name, {:update, %{page_number: page_number, data: data}})
  end

  def get_state(page_number, name \\ @name) do
    GenServer.call(name, {:get, page_number})
  end

  def handle_cast({:update, %{page_number: page_number, data: data}}, state) do
    state = Map.put(state, "page_#{page_number}", data)
    {:noreply, state}
  end

  def handle_call({:get, page_number}, _, state) do
    {:reply, Map.get(state, "page_#{page_number}"), state}
  end
end
