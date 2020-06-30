defmodule Dripio.Http.DeviceTypesHandler do
  alias Dripio.DeviceType
  alias Dripio.Repo

  @permissions %{
    read: ["can_see_device_types"],
    write: ["can_edit_device_types"]
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
        DeviceType.get()
        |> Enum.map(fn t -> DeviceType.export(t) end)
        |> Jason.encode()

      {json, req, state}
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      with {:ok, json, _} <- read_body(req),
           {:ok, type_params} <- Jason.decode(json) do
        changeset = DeviceType.create_device_type(%DeviceType{}, type_params)

        req =
          case Repo.insert(changeset) do
            {:ok, type} ->
              {:ok, new_type_json} =
                type
                |> DeviceType.export()
                |> Jason.encode()

              :cowboy_req.reply(201, %{}, new_type_json, req)

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
