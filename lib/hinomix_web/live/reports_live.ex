defmodule HinomixWeb.ReportsLive do
  use HinomixWeb, :live_view

  alias Hinomix.Reports

  def mount(_params, _session, socket) do
    reports = Reports.list_reports()
    {:ok, assign(socket, :reports, reports), temporary_assigns: [reports: []]}
  end

  def render(assigns) do
    ~H"""
    <table border="1">
      <thead>
        <th>Campaign ID</th>
        <th>Source</th>
        <th>Total clicks</th>
        <th>Total revenue</th>
      </thead>
      <tbody>
        <%= for report <- @reports do %>
          <tr>
            <td>{report.campaign_id}</td>
            <td>{String.capitalize(report.source)}</td>
            <td>{report.total_clicks}</td>
            <td>{report.total_revenue}</td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
