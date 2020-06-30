# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :dripio_core, ecto_repos: [Dripio.Repo]

config :bcrypt_elixir, log_rounds: 4

config :dripio_core, Dripio.Http.Guardian,
  issuer: "dripio_core",
  secret_key: "swlzMsMAKpfdOYUpQQPilHq4IJrY+sDxdQgVExjtAOH+ASFYcl02gmFeqox8hBOn"

config :dripio_core,
  site_url: "dashboard.dripio.com",
  # ms
  loop_delay: 1000,
  # s
  reset_email_timeout: 10,
  # s
  reset_token_lifetime: 600,
  # s
  confirm_email_timeout: 10,
  # s
  confirm_token_lifetime: 600,
  # s
  device_online_timeout: 10

config :opencensus, :reporters,
  # oc_reporter_jaeger: [hostname: 'localhost',
  #                      port: 6831, ##  default for compact protocol
  #                      service_name: "chat",
  #                      service_tags: %{"key" => "value"}],
  oc_reporter_zipkin: [
    address: 'http://localhost:9411/api/v2/spans',
    local_endpoint: %{"serviceName" => "dripio_core"}
  ]

config :opencensus, :sampler, {:oc_sampler_always, []}

config :nanoid,
  size: 5, # uniq per 100000 generations
  alphabet: "_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :dripio_core, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:dripio_core, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"
