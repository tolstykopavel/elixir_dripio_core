defmodule Dripio.Http.WebsocketHandler do
  require Dripio.Mqtt.Client

  alias Phoenix.PubSub
  alias Dripio.Device

  def init(req, state) do
    case :cowboy_req.match_qs([:token], req) do
      %{token: token} ->
        case Dripio.Http.Guardian.decode_and_verify(token) do
          {:ok, %{"perms" => perms, "sub" => user_id}} ->
            state = state ++ [perms: perms, user_id: user_id]
            {:cowboy_websocket, req, state, %{idle_timeout: :infinity}}

          _ ->
            {:stop, req, state}
        end

      _ ->
        {:stop, req, state}
    end
  end

  def websocket_init(state) do
    user_id = Keyword.get(state, :user_id)
    perms = Keyword.get(state, :perms)

    PubSub.subscribe(Dripio.PubSub, "control/user/" <> user_id)

    Enum.each(perms, fn permission ->
      case granted_data_type(permission) do
        nil ->
          :ok

        channel ->
          PubSub.subscribe(Dripio.PubSub, "control/data/" <> channel)
      end
    end)

    {:ok, state}
  end

  def websocket_info({:device, json}, state) do
    {:reply, {:text, json}, state}
  end

  def websocket_info({:log, json}, state) do
    {:reply, {:text, json}, state}
  end

  def websocket_info(_info, state) do
    {:ok, state}
  end

  #
  def websocket_handle({:text, json}, state) do
    %{
      "type" => type,
      "data" => data
    } = Jason.decode!(json)

    case type do
      "mqttCommand" ->
        %{
          "deviceId" => device_id,
          "locationId" => location_id,
          "topic" => topic,
          "data" => data
        } = data

        device = Device.get(%{location_id: location_id, device_id: device_id})

        case topic do
          "loopback" -> Device.loopback(device, data)
          "ota" -> Device.ota(device, data)
          "cmd" -> Device.cmd(device, data)
          topic -> Device.mqtt(device, topic, data)
        end

      _ ->
        IO.inspect(data)
    end

    # {:reply, frame, state}
    {:ok, state}
  end

  def websocket_handle(_frame, state) do
    {:ok, state}
  end

  #

  defp granted_data_type(p) do
    Map.get(
      %{
        "can_see_users" => "users",
        "can_see_location_details" => "location_details",
        "can_see_locations" => "locations",
        "can_see_device_details" => "device_details",
        "can_see_devices" => "devices"
      },
      p,
      nil
    )
  end
end
