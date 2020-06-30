defmodule Dripio.Mqtt.Client do
  use Tortoise.Handler

  alias Dripio.Mqtt.Client.Device, as: MqttDevice

  defmacro publish(topic, data, qos \\ 0) do
    [client_id: mqtt_client_id] = Application.get_env(:dripio_core, Dripio.Mqtt.Client)

    quote do
      Tortoise.publish(unquote(mqtt_client_id), unquote(topic), unquote(data), qos: unquote(qos))
    end
  end

  def init(args) do
    {:ok, args}
  end

  def start_link() do
    [client_id: mqtt_client_id] = Application.get_env(:dripio_core, Dripio.Mqtt.Client)
    cert_dir = Application.app_dir(:dripio_core, "priv/ssl")

    Tortoise.Supervisor.start_child(
      client_id: mqtt_client_id,
      handler: {Dripio.Mqtt.Client, []},
      server: {
        Tortoise.Transport.SSL,
        host: 'mqtt.dripio.com',
        port: 8883,
        versions: [:"tlsv1.2"],
        cacertfile: Path.join(cert_dir, 'ca.crt')

        # keyfile: 'priv/client.key',
        # certfile: 'priv/client.pem',

        # customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
      },
      subscriptions: [
        # TODO: move to config
        {"u/+", 0},
        {"u/+/status", 0},
        {"u/+/cmd", 0},
        {"u/+/ota", 0},
        {"u/+/loopback", 0},
        {"d/+/loopback", 0}
      ]
    )
  end

  def connection(_status, state) do
    {:ok, state}
  end

  #

  def handle_message(
        ["u", device_id, topic],
        payload,
        state
      ) do
    MqttDevice.dispatch(topic, device_id, payload)
    {:ok, state}
  end

  def handle_message(["u", device_id], payload, state) do
    MqttDevice.dispatch(:root, device_id, payload)
    {:ok, state}
  end

  def handle_message(["d" | _] = topic, payload, state) do
    :syn.publish(:device_listeners, {topic, payload})
    {:ok, state}
  end

  def handle_message(_topic, _payload, state) do
    {:ok, state}
  end

  #

  def subscription(_status, _topic_filter, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    IO.inspect("mqtt terminated")
    # tortoise doesn't care about what you return from terminate/2,
    # that is in alignment with other behaviours that implement a
    # terminate-callback
    :ok
  end
end
