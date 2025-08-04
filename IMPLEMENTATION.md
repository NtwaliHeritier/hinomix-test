## IMPLEMENTATION OVERVIEW

This section outlines the key steps and strategies used to develop the project.

## API Response Caching

To improve performance and reduce unnecessary API calls, I implemented a caching layer using GenServers. This allowed us to avoid hitting the third-party API on every report generation request.

To ensure the cached data remains relatively fresh, the GenServer state is refreshed periodically. This is achieved by scheduling a worker to run every 5 minutes, updating both the cache and the underlying reports table.

## Handling Data Discrepancies

Discrepancies between the internal data (clicks table) and the external reports arise due to two main factors:

1. Pagination of API responses
   The API only returns a portion of the full dataset (paginated), whereas our database stores all click records. This makes direct comparisons incomplete or misleading.

2. Incorrect use of report_date field
   Initially, the implementation ignored the report_date provided by the API, leading to inaccurate aggregations.

To address the second issue, I updated the logic to respect the report_date, which resulted in more accurate and reliable reports.

## LiveView Interface

I developed a simple Phoenix LiveView interface consisting of a form and a results table. The user can specify the number of pages to include in the report, and the results are displayed accordingly.

This interface is available at localhost:4000.

The report data is served from the in-memory cache (GenServer state). If a user requests data for a page that hasn't been cached yet, a background job is automatically enqueued to fetch the data from the API. While the first request may take longer, subsequent requests are nearly instantaneous due to caching.
