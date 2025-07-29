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
    """
  end
end
