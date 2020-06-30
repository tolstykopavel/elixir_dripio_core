defmodule Dripio.Http.DeviceModelHandler do
  alias Dripio.Repo
  alias Dripio.DeviceModel

  use Dripio.Http.Handler

  @permissions %{
    read: ["can_see_device_models"],
    write: ["can_edit_device_models"]
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
      model_id = :cowboy_req.binding(:model_id, req)

      {:ok, json} =
        DeviceModel.get_by_id(model_id)
        |> DeviceModel.export()
        |> Jason.encode()

      {json, req, state}
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      with model_id <- :cowboy_req.binding(:model_id, req),
           {:ok, json, _} <- read_body(req),
           {:ok, model_params} <- Jason.decode(json) do
        changeset =
          DeviceModel.get_by_id(model_id)
          |> DeviceModel.change_device_model(model_params)

        case Repo.update(changeset) do
          {:ok, _device} ->
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
      model_id = :cowboy_req.binding(:model_id, req)

      model = DeviceModel.get_by_id(model_id)

      case Repo.delete(model) do
        {:ok, _device} ->
          :cowboy_req.reply(200, req)

        _ ->
          :cowboy_req.reply(500, req)
      end

      {:stop, req, state}
    end
  end
end
