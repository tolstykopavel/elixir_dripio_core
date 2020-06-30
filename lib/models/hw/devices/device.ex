defmodule Dripio.Device do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  alias Dripio.Repo

  alias Dripio.Location
  alias Dripio.Device

  use Dripio.Trace

  alias Dripio.Mqtt.Client.Device, as: MqttDevice

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "devices" do
    field(:title, :string, default: "No title")
    field(:data, :map)
    field(:status, :boolean, default: false)
    field(:notes, :string)

    field(:mcu_status, :boolean, default: false)
    field(:mcu_errors, {:array, :binary}, default: [])

    # has_many :units, Dripio.Unit

    belongs_to(:device_model, Dripio.DeviceModel)
    belongs_to(:software, Dripio.DeviceSoftware)
    belongs_to(:location, Dripio.Location, type: Ecto.ShortUUID)
    belongs_to(:lot, Dripio.HW.Lot, type: Ecto.ShortUUID)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def change_device(model, params \\ %{}) do
    Trace.wrap do
      model
      |> cast(params, [
        :title,
        :data,
        :status,
        :notes,
        :mcu_status,
        :mcu_errors,
        :device_model_id,
        :software_id,
        :location_id,
        :lot_id
      ])
    end
  end

  def create_device(model, params \\ %{}) do
    Trace.wrap do
      model
      |> change_device(params)
      |> cast(params, [:id])
      |> validate_required([:device_model_id, :location_id])
      |> foreign_key_constraint(:device_model_id)
      |> foreign_key_constraint(:software_id)
      |> foreign_key_constraint(:location_id)
      |> foreign_key_constraint(:lot_id)
    end
  end

  #

  def get(opts) do
    Trace.wrap do
      case get_all(opts) do
        [%Dripio.Device{} = d | _] -> d
        %Dripio.Device{} = d -> d
        _ -> nil
      end
    end
  end

  def get_by_id(id) do
    case Repo.get(Device, id) do
      nil ->
        {:error, :device_not_found}

      device ->
        {:ok, device}
    end
  end

  def get_all() do
    Repo.all(Device)
  end

  def get_all(opts) do
    _get_all(opts)
  catch
    _ -> :error
    _, _ -> :error
  end

  defp _get_all(%{user_id: user_id, location_id: location_id, device_id: device_id}) do
    if Location.check_owner(user_id, location_id) do
      get(%{location_id: location_id, device_id: device_id})
    else
      raise "Device #{device_id} does not belong to location #{location_id}"
    end
  end

  defp _get_all(%{location_id: :undefined, device_id: device_id}) do
    Repo.all(
      from(d in Device,
        where: d.id == ^device_id
      )
    )
  end

  defp _get_all(%{location_id: location_id, device_id: device_id}) do
    Repo.all(
      from(d in Device,
        where: d.id == ^device_id,
        where: d.location_id == ^location_id
      )
    )
  end

  defp _get_all(%{user_id: user_id, location_id: location_id}) do
    if Location.check_owner(user_id, location_id) do
      Repo.all(
        from(d in Device,
          where: d.location_id == ^location_id
        )
      )
    else
      raise "User #{user_id} have no rights to access location #{location_id}"
    end
  end

  defp _get_all(%{location_id: :undefined}) do
    Repo.all(Device)
  end

  defp _get_all(%{location_id: location_id}) do
    Repo.all(
      from(d in Device,
        where: d.location_id == ^location_id
      )
    )
  end

  #

  def set_offline(%{"id" => id}) do
    set_device_status(id, false)
  end

  def set_online(%{"id" => id}) do
    set_device_status(id, true)
  end

  def set_device_status(id, status) do
    Trace.wrap do
      with {:ok, device} <- get_by_id(id) do
        set_device_data(
          device,
          %{status: status},
          "Device #{id} is #{
            if status do
              "online"
            else
              "offline"
            end
          }"
        )
      end
    end
  end

  def set_device_data(device, data, message \\ nil) do
    Trace.wrap do
      {:ok, updated_device} =
        Device.change_device(device, data)
        |> Repo.update()

      broadcast_update(updated_device, message)
    end
  end

  #

  def broadcast_update(device, message \\ nil) do
    Trace.wrap do
      to_ws = %{
        type: "device",
        payload: export(device)
      }

      {:ok, json} = Jason.encode(to_ws)

      device = Repo.preload(device, [:location])
      users = Repo.preload(device.location, [:users]).users

      Phoenix.PubSub.broadcast(Dripio.PubSub, "control/data/devices", {:device, json})

      if message do
        broadcast_log("control/data/devices", device.id, %{
          message: message
        })
      end

      Enum.each(users, fn u ->
        Phoenix.PubSub.broadcast(Dripio.PubSub, "control/user" <> u.id, {:device, json})

        if message do
          broadcast_log("control/user" <> u.id, device.id, %{
            message: message
          })
        end
      end)
    end
  end

  def broadcast_log(topic, reporterId, data) do
    Trace.wrap do
      to_ws = %{
        type: "log",
        payload: %{
          reporterId: reporterId,
          data: data
        }
      }

      {:ok, json} = Jason.encode(to_ws)

      Phoenix.PubSub.broadcast(Dripio.PubSub, topic, {:log, json})
    end
  end

  #

  def loopback(device, data, :sync) do
    device
    |> mqtt("loopback", data, :sync)
  end

  def loopback(device, data, _async \\ nil, callback \\ fn -> nil end) do
    device
    |> mqtt("loopback", data, :async, fn d ->
      Device.broadcast_log("control/data/devices", device.id, %{
        message: "loopback: #{inspect(d)}"
      })

      callback.()
    end)
  end

  #

  def ota(device, data, :sync) do
    device
    |> mqtt("ota", data, :sync)
  end

  def ota(device, data, _async \\ nil, callback \\ fn -> nil end) do
    device
    |> mqtt("ota", data, :async, fn d ->
      Device.broadcast_log("control/data/devices", device.id, %{
        message: "sw_version: #{inspect(d)}"
      })

      callback.(d)
    end)
  end

  #

  def cmd(device, data, :sync) do
    device
    |> mqtt("cmd", data, :sync)
  end

  def cmd(device, data, _async \\ nil, callback \\ fn _arg -> nil end) do
    device
    |> mqtt("cmd", data, :async, fn d ->
      bits = Dripio.MCU.to_bits(d)

      Device.broadcast_log("control/data/devices", device.id, %{
        message: "cmd_response: #{inspect(d)}; as_bits: #{inspect(bits)}"
      })

      callback.(d)
    end)
  end

  #

  def mqtt(device, topic, data, :sync) do
    MqttDevice.publish(topic, {device.id, data})
  end

  def mqtt(device, topic, data, _async \\ nil, callback \\ fn _arg -> nil end) do
    Task.start(fn ->
      d = MqttDevice.publish(topic, {device.id, data})
      callback.(d)
    end)
  end

  #

  def export(device) do
    %{
      id: device.id,
      title: device.title,
      data: device.data,
      status: device.status,
      notes: device.notes,
      mcu_status: device.mcu_status,
      mcu_errors: device.mcu_errors,

      # model: device.device_model.id,
      # fw: device.software.version,

      location_id: device.location_id
    }
  end
end
