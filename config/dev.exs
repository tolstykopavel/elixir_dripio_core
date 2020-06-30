use Mix.Config

config :dripio_core, Dripio.Mqtt.Client,
  client_id: "dripio_mqtt_dev_#{System.get_env("DRIPIO_ENV")}"

config :dripio_core, Dripio.Mailer, adapter: Bamboo.TestAdapter

config :dripio_core, Dripio.Repo,
  # database: "dripio_dev",
  # username: "dripio",
  # password: "QADggEBAGUTPLNnmoQOjApfywGop7XlxoKOG8h",
  # socket_dir: "/tmp/cloudsql/atlantean-force-165018:us-east1:dripio-db",
  # pool_size: 15

  # database: "dripio-prod",
  # username: "dripio",
  # password: "QADggEBAGUTPLNnmoQOjApfywGop7XlxoKOG8h",
  # # socket_dir: "/tmp/cloudsql/atlantean-force-165018:us-east1:dripio-db",
  # hostname: "10.112.192.3",
  # port: 5432,
  # pool_size: 15

  database: "db_xcuseme",
  username: "victor",
  password: "ew8hEF0ldNqhq7wE",
  # socket_dir: "/tmp/cloudsql/atlantean-force-165018:us-east1:dripio-db",
  hostname: "35.202.228.229",
  port: 5432,
  pool_size: 15

