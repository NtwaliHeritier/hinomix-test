defmodule HinomixWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :hinomix

  @session_options [
    store: :cookie,
    key: "_my_app_key",
    signing_salt: "PROySmFhEHqhoDAwF77G8MQc8hUyg6vidu4kA3+KTfKMMLEmPbfCY/r/hPxDVwE0"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Session, @session_options

  plug Plug.Static,
    at: "/",
    from: :hinomix,
    gzip: false,
    only: HinomixWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :hinomix
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug HinomixWeb.Router
end
