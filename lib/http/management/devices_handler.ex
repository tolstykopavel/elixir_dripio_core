defmodule Dripio.Http.DevicesHandler do
  alias Dripio.Repo
  alias Dripio.Device

  @permissions %{
    read: ["can_see_devices"],
    write: ["can_edit_devices"]
  }
  use Dripio.Http.Handler

  def allowed_methods(req, state) do
    {["GET", "HEAD", "PUT", "OPTIONS"], req, state}
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

      {:ok, json} =
        Device.get_all(%{
          location_id: location_id
        })
        # |> Repo.preload([:device_model, :software, :location])
        |> Enum.map(fn device -> Device.export(device) end)
        |> Jason.encode()

      {json, req, state}
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      location_id = :cowboy_req.binding(:location_id, req)

      {:ok, json, _} = read_body(req)
      {:ok, device_params} = Jason.decode(json)

      changeset =
        Device.create_device(
          %Device{},
          device_params
          |> Map.put("location_id", location_id)
          |> Map.put("device_model_id", 1)
        )

      req =
        case Repo.insert(changeset) do
          {:ok, device} ->
            {:ok, new_device_json} =
              device
              # |> Repo.preload(:users)
              |> Device.export()
              |> Jason.encode()

            :cowboy_req.reply(201, %{}, new_device_json, req)

          {:error, _changeset} ->
            :cowboy_req.reply(500, req)
        end

      {:stop, req, state}
    end
  end
end