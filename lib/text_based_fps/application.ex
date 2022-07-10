defmodule TextBasedFPS.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @typep boot_mode :: :phoenix | :"cli.server" | :"cli.client"

  @server_processes [
    TextBasedFPS.ServerAgent,
    TextBasedFPS.Process.RoomSupervisor,
    TextBasedFPS.Process.Players
  ]

  def start(_type, _args) do
    # Starts by default in :phoenix boot mode (`mix phx.server`).
    # It can also be started with `mix cli.server` and `mix cli.client`.
    children =
      Application.get_env(TextBasedFPS.Application, :boot_mode, :phoenix)
      |> supervisor_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TextBasedFPS.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TextBasedFPSWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @spec supervisor_children(boot_mode) :: list()
  defp supervisor_children(:phoenix) do
    [
      # Start the Telemetry supervisor
      TextBasedFPSWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TextBasedFPS.PubSub},
      # Start the Endpoint (http/https)
      TextBasedFPSWeb.Endpoint
    ] ++ @server_processes
  end

  defp supervisor_children(:"cli.server"), do: @server_processes

  defp supervisor_children(:"cli.client"), do: []
end
