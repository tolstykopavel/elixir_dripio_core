defmodule Dripio.Http.DeviceHandler do
  alias Dripio.Repo
  alias Dripio.Device

  use Dripio.Http.Handler

  @permissions %{
    read: ["can_see_device_details"],
    write: ["can_edit_device_details"]
  }

  def allowed_methods(req, state) do
    {["GET", "PATCH", "DELETE", "HEAD", "OPTIONS"], req, state}
  end

  def content_types_provided(req, state) do
    {[{"application/json", :to_json}], req, state}
  end

  def content_types_accepted(req, state) do
    {[{{"application", "json", :*}, :from_json}], req, state}
  end

  #

  def to_json(req, state) do
    Trace.wrap do
      location_id = :cowboy_req.binding(:location_id, req)
      device_id = :cowboy_req.binding(:device_id, req)

      {:ok, json} =
        Device.get(%{
          location_id: location_id,
          device_id: device_id
        })
        |> Device.export()
        |> Jason.encode()

      {json, req, state}
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      location_id = :cowboy_req.binding(:location_id, req)
      device_id = :cowboy_req.binding(:device_id, req)

      {:ok, json, _} = read_body(req)
      {:ok, device_params} = Jason.decode(json)

      changeset =
        Device.get(%{
          location_id: location_id,
          device_id: device_id
        })
        |> Device.change_device(device_params)

      case Repo.update(changeset) do
        {:ok, _device} ->
          :cowboy_req.reply(204, req)

        {:error, _changeset} ->
          :cowboy_req.reply(500, req)
      end

      {:stop, req, state}
    end
  end

  def delete_resource(req, state) do
    Trace.wrap do
      location_id = :cowboy_req.binding(:location_id, req)
      device_id = :cowboy_req.binding(:device_id, req)

      device =
        Device.get(%{
          location_id: location_id,
          device_id: device_id
        })

      case Repo.delete(device) do
        {:ok, _device} ->
          :cowboy_req.reply(200, req)

        _ ->
          :cowboy_req.reply(500, req)
      end

      {:stop, req, state}
    end
  end
end
