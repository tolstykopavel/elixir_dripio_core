defmodule Dripio.Http.UserZonesHandler do
  alias Dripio.Repo
  alias Dripio.Location
  alias Dripio.Zone

  @permissions %{
    read: ["owner", "can_see_zones"],
    write: ["owner", "can_edit_zones"]
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
      location_id = :cowboy_req.binding(:location_id, req)

      {:ok, json} =
        Zone.get_all(%{
          user_id: user_id,
          location_id: location_id
        })
        # |> Repo.preload([:device_model, :software, :location])
        |> Enum.map(fn zone -> Zone.export(zone) end)
        |> Jason.encode()

      {json, req, state}
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      user_id = :cowboy_req.binding(:user_id, req)
      location_id = :cowboy_req.binding(:location_id, req)

      {:ok, json, _} = read_body(req)
      {:ok, zone_params} = Jason.decode(json)

      req =
        if Location.check_owner(user_id, location_id) do
          changeset =
            Zone.change_zone(
              %Zone{},
              zone_params
              |> Map.put("location_id", location_id)
            )

          case Repo.insert(changeset) do
            {:ok, zone} ->
              {:ok, new_zone_json} =
                zone
                # |> Repo.preload(:users)
                |> Zone.export()
                |> Jason.encode()

              :cowboy_req.reply(201, %{}, new_zone_json, req)

            {:error, _changeset} ->
              :cowboy_req.reply(500, req)
          end
        else
          :cowboy_req.reply(500, req)
        end

      {:stop, req, state}
    end
  end
end
