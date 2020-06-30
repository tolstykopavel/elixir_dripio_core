defmodule Dripio.Http.DeviceTypeHandler do
  alias Dripio.Repo
  alias Dripio.DeviceType

  use Dripio.Http.Handler

  @permissions %{
    read: ["can_see_device_types"],
    write: ["can_edit_device_types"]
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
      type_id = :cowboy_req.binding(:type_id, req)

      {:ok, json} =
        DeviceType.get_by_id(type_id)
        |> DeviceType.export()
        |> Jason.encode()

      {json, req, state}
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      with type_id <- :cowboy_req.binding(:type_id, req),
           {:ok, json, _} <- read_body(req),
           {:ok, type_params} <- Jason.decode(json) do
        changeset =
          DeviceType.get_by_id(type_id)
          |> DeviceType.change_device_type(type_params)

        case Repo.update(changeset) do
          {:ok, _type} ->
            :cowboy_req.reply(204, req)

          {:error, _changeset} ->
            :cowboy_req.reply(500, req)
        end

        {:stop, req, state}
      end
    end
  end

  def delete_resource(req, state) do
    Trace.wrap do
      type_id = :cowboy_req.binding(:type_id, req)

      type = DeviceType.get_by_id(type_id)

      case Repo.delete(type) do
        {:ok, _type} ->
          :cowboy_req.reply(200, req)

        _ ->
          :cowboy_req.reply(500, req)
      end

      {:stop, req, state}
    end
  end
end
