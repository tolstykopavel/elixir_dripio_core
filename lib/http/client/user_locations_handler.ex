defmodule Dripio.Http.UserLocationsHandler do
  alias Dripio.Repo
  alias Dripio.Location

  @permissions %{
    read: ["owner", "can_see_locations"],
    write: ["owner", "can_edit_locations"]
  }
  use Dripio.Http.Handler

  def allowed_methods(req, state) do
    {["GET", "PUT", "HEAD", "OPTIONS"], req, state}
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
      user_id = :cowboy_req.binding(:user_id, req)

      {:ok, json} =
        Location.get_by_user_id(user_id)
        |> Enum.map(fn location -> Location.export(location) end)
        |> Jason.encode()

      {json, req, state}
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      user_id = :cowboy_req.binding(:user_id, req)

      {:ok, json, _} = read_body(req)
      {:ok, location_params} = Jason.decode(json)

      changeset =
        Location.create_location(%Location{}, location_params |> Map.put("owner_id", user_id))

      req =
        case Repo.insert(changeset) do
          {:ok, location} ->
            {:ok, new_location_json} =
              location
              |> Repo.preload(:users)
              |> Location.export()
              |> Jason.encode()

            :cowboy_req.reply(201, %{}, new_location_json, req)

          {:error, _changeset} ->
            :cowboy_req.reply(500, req)
        end

      {:stop, req, state}
    end
  end
end
