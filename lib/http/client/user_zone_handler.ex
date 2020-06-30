defmodule Dripio.Http.UserZoneHandler do
  alias Dripio.Repo
  alias Dripio.Zone

  use Dripio.Http.Handler

  @permissions %{
    read: ["owner", "can_see_zone_details"],
    write: ["owner", "can_edit_zone_details"]
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
      user_id = :cowboy_req.binding(:user_id, req)
      location_id = :cowboy_req.binding(:location_id, req)
      zone_id = :cowboy_req.binding(:zone_id, req)

      {:ok, json} =
        Zone.get(%{
          user_id: user_id,
          location_id: location_id,
          zone_id: zone_id
        })
        |> Zone.export()
        |> Jason.encode()

      {json, req, state}
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      user_id = :cowboy_req.binding(:user_id, req)
      location_id = :cowboy_req.binding(:location_id, req)
      zone_id = :cowboy_req.binding(:zone_id, req)

      {:ok, json, _} = read_body(req)
      {:ok, zone_params} = Jason.decode(json)

      changeset =
        Zone.get(%{
          user_id: user_id,
          location_id: location_id,
          zone_id: zone_id
        })
        |> Zone.change_zone(zone_params)

      case Repo.update(changeset) do
        {:ok, _zone} ->
          :cowboy_req.reply(204, req)

        {:error, _changeset} ->
          :cowboy_req.reply(500, req)
      end

      {:stop, req, state}
    end
  end

  def delete_resource(req, state) do
    Trace.wrap do
      user_id = :cowboy_req.binding(:user_id, req)
      location_id = :cowboy_req.binding(:location_id, req)
      zone_id = :cowboy_req.binding(:zone_id, req)

      zone =
        Zone.get(%{
          user_id: user_id,
          location_id: location_id,
          zone_id: zone_id
        })

      case Repo.delete(zone) do
        {:ok, _zone} ->
          :cowboy_req.reply(200, req)

        {:error, _changeset} ->
          :cowboy_req.reply(500, req)
      end

      {:stop, req, state}
    end
  end
end
