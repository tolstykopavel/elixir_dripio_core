use Mix.Config

config :dripio_core, Dripio.Mqtt.Client,
  client_id: "dripio_mqtt_prod_#{System.get_env("DRIPIO_ENV")}"

config :dripio_core, Dripio.Mailer,
  adapter: Bamboo.MandrillAdapter,
  api_key: "XxM12buY1KmYHlqzkxKuIg"

config :dripio_core, Dripio.Repo,
  # database: "dripio_core_repo",
  # username: "dripio",
  # password: "dripio",
  # hostname: "172.17.0.1"
  database: "dripio-prod",
  username: "dripio",
  password: "QADggEBAGUTPLNnmoQOjApfywGop7XlxoKOG8h",
  # socket_dir: "/tmp/cloudsql/atlantean-force-165018:us-east1:dripio-db",
  hostname: "10.112.192.3",
  port: 5432,
  pool_size: 15
