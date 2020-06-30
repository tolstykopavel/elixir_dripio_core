defmodule DripioCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    :ok = :syn.init()

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: DripioCore.Worker.start_link(arg)
      # {DripioCore.Worker, arg},
      supervisor(Phoenix.PubSub.PG2, [Dripio.PubSub, []]),
      Dripio.Repo,
      worker(Dripio.Http.Webserver, []),
      worker(DripioCore.State, []),
      worker(Dripio.Mqtt.Client, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DripioCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
