defmodule Dripio.Http.DeviceModelsHandler do
  alias Dripio.DeviceModel
  alias Dripio.Repo

  @permissions %{
    read: ["can_see_device_models"],
    write: ["can_edit_device_models"]
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
      {:ok, json} =
        DeviceModel.get()
        |> Enum.map(fn m -> DeviceModel.export(m) end)
        |> Jason.encode()

      {json, req, state}
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      with {:ok, json, _} <- read_body(req),
           {:ok, model_params} <- Jason.decode(json) do
        changeset =
          DeviceModel.create_device_model(
            %DeviceModel{},
            model_params
            |> Map.put("device_type_id", 1)
          )

        req =
          case Repo.insert(changeset) do
            {:ok, model} ->
              {:ok, new_model_json} =
                model
                |> DeviceModel.export()
                |> Jason.encode()

              :cowboy_req.reply(201, %{}, new_model_json, req)

            {:error, _changeset} ->
              :cowboy_req.reply(500, req)
          end

        {:stop, req, state}
      else
        _ -> :cowboy_req.reply(500, req)
      end
    end
  end
end
