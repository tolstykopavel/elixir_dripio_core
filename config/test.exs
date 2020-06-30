use Mix.Config

config :dripio_core, Dripio.Mqtt.Client,
  client_id: "dripio_mqtt_test_#{System.get_env("DRIPIO_ENV")}"

config :dripio_core, Dripio.Mailer, adapter: Bamboo.TestAdapter

config :dripio_core, Dripio.Repo,
  database: "dripio_test",
  username: "dripio",
  password: "QADggEBAGUTPLNnmoQOjApfywGop7XlxoKOG8h",
  socket_dir: "/tmp/cloudsql/atlantean-force-165018:us-east1:dripio-db",
  pool_size: 15
