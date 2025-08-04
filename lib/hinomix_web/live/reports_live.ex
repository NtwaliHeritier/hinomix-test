defmodule HinomixWeb.ReportsLive do
  use HinomixWeb, :live_view

  alias Hinomix.Reports

  @default_page_number 4

  def mount(_params, _session, socket) do
    reports = Reports.get_reports_by_page(@default_page_number)

    if connected?(socket) do
      Process.send_after(self(), {:refresh, @default_page_number}, :timer.seconds(1))
    end

    {:ok, assign(socket, %{reports: reports, page_number: @default_page_number}),
     temporary_assigns: [reports: []]}
  end

  def render(assigns) do
    ~H"""
    <div :if={!@reports}>Loading...</div>
    <div :if={@reports}>
      <form phx-submit="generate-report">
        <input
          type="number"
          name="page-number"
          placeholder="Enter page number"
          min="1"
          max="15"
          style="width: 150px;"
        />
        <button>Generate Report</button>
      </form>
      <br />
      <h3>Report for {@page_number} pages</h3>
      <table border="1">
        <thead>
          <th>Report ID</th>
          <th>Campaign ID</th>
          <th>Source</th>
          <th>Total clicks</th>
          <th>Total revenue</th>
          <th>Report date</th>
        </thead>
        <tbody>
          <%= for report <- @reports do %>
            <tr>
              <td>{report.report_id}</td>
              <td>{report.campaign_id}</td>
              <td>{String.capitalize(report.source)}</td>
              <td>{report.total_clicks}</td>
              <td>{report.total_revenue}</td>
              <td>{report.report_date}</td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  def handle_event("generate-report", %{"page-number" => page_number}, socket) do
    reports =
      case Reports.get_reports_by_page(page_number) do
        nil ->
          Hinomix.Jobs.ReportIngestionJob.new(%{"max_pages" => String.to_integer(page_number)})
          |> Oban.insert()

          Process.send_after(self(), {:refresh, page_number}, :timer.seconds(1))
          Hinomix.Servers.Cache.update_state("max_pages", String.to_integer(page_number))

          nil

        reports ->
          reports
      end

    {:noreply, socket |> assign(%{reports: reports, page_number: page_number})}
  end

  def handle_info({:refresh, page_number}, socket) do
    reports = Reports.get_reports_by_page(page_number)

    if is_nil(reports) do
      Process.send_after(self(), {:refresh, page_number}, :timer.seconds(1))
    end

    {:noreply, socket |> assign(:reports, reports)}
  end
end
