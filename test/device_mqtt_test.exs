defmodule Dripio.Http.DeviceMqtt.Test do
  use ExUnit.Case
  use Dripio.Http.Test

  require Dripio.Mqtt.Client

  alias Dripio.Device
  alias Dripio.Mqtt.Client, as: MqttClient

  setup do
    :application.ensure_all_started(:tortoise)
    # wait for all subscriptions up
    :timer.sleep(5000)
  end

  test "Device MQTT Loopback" do
    [device | _] = Device.get_all()

    data = "qwe"

    spawn(fn ->
      task =
        Task.async(fn ->
          receive do
            message ->
              IO.inspect(message)
              message
          after
            5000 -> {:error, :timeout}
          end
        end)

      :syn.join(:device_listeners, task.pid)

      response =
        case Task.await(task) do
          {["d", did, "loopback"], d} ->
            # assert ^lid = device.location_id
            assert ^did = device.id

            MqttClient.publish("u/#{did}/loopback", d)

            d

          _ ->
            assert false
        end
    end)

    response = Device.loopback(device, data, :sync)

    assert ^response = data
  end
end
