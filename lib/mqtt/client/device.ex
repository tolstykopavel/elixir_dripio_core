defmodule Dripio.Mqtt.Client.Device do
  require Dripio.Mqtt.Client

  alias Dripio.Device
  alias Dripio.Mqtt.Client, as: MqttClient

  #

  def publish(topic, {did, data}, timeout \\ 5000) do
    id = Nanoid.generate()

    task =
      Task.async(fn ->
        receive do
          {^topic, ^did, data} -> data
        after
          timeout -> {:error, :timeout}
        end
      end)

    MqttClient.publish("d/#{did}/#{topic}", "#{id};#{data}")
    :syn.register(id, task.pid, :undefined)
    Task.await(task, :infinity)
  end

  #

  def dispatch("status", did, data) do
    case data do
      "online" ->
        Device.set_online(%{"id" => did})

      "offline" ->
        Device.set_offline(%{"id" => did})

      "mcu_startup_seq_fail" ->
        Dripio.MCU.set_mcu_status(%{"id" => did}, false, "mcu_startup_seq_fail")
        :ok

      "0" ->
        Dripio.MCU.set_mcu_status(%{"id" => did}, true)
        IO.inspect("======== mcu response success ==========")
        :ok

      error_code ->
        Dripio.MCU.set_mcu_status(%{"id" => did}, false, error_code)
        # code = Dripio.MCU.to_bits(error_code)
        # IO.inspect("======== mcu response ==========")
        # IO.inspect(code)
        # IO.inspect("==================")
        # code
        :ok
    end
  end

  def dispatch(topic, did, data) do
    case String.split(data, ";") do
      [request_id, data] ->
        case :syn.find_by_key(request_id) do
          pid when is_pid(pid) ->
            send(pid, {topic, did, data})

          _ ->
            throw("Unexpected message from device [#{did}]: #{inspect(data)}")
        end

      _ ->
        throw("Received message from device [#{did}] without request_id: #{inspect(data)}")
    end
  end
end
