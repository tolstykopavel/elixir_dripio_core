defmodule Dripio.Http.DeviceModelSoftwareHandler do
  alias Dripio.DeviceSoftware
  alias Dripio.Repo

  @permissions %{
    read: ["can_see_device_softwares"],
    write: ["can_edit_device_softwares"]
  }
  use Dripio.Http.Handler

  def allowed_methods(req, state) do
    {["GET", "HEAD", "PATCH", "DELETE", "OPTIONS"], req, state}
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
      with software_id <- :cowboy_req.binding(:software_id, req) do
        {:ok, json} =
          DeviceSoftware.get_by_id(software_id)
          |> DeviceSoftware.export()
          |> Jason.encode()

        {json, req, state}
      else
        _ ->
          req = :cowboy_req.reply(500, req)
          {:stop, req, state}
      end
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      software_id = :cowboy_req.binding(:software_id, req)

      {:ok, json, _} = read_body(req)
      {:ok, sw_params} = Jason.decode(json)

      changeset =
        DeviceSoftware.get_by_id(software_id)
        |> Map.drop([:bin])
        |> DeviceSoftware.change_software(sw_params)

      case Repo.update(changeset) do
        {:ok, _sw} ->
          :cowboy_req.reply(204, req)

        {:error, _changeset} ->
          :cowboy_req.reply(500, req)
      end

      {:stop, req, state}
    end
  end

  def delete_resource(req, state) do
    Trace.wrap do
      software_id = :cowboy_req.binding(:software_id, req)

      sw = DeviceSoftware.get_by_id(software_id)

      case Repo.delete(sw) do
        {:ok, _device} ->
          :cowboy_req.reply(200, req)

        _ ->
          :cowboy_req.reply(500, req)
      end

      {:stop, req, state}
    end
  end
end
