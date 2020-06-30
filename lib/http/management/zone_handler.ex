defmodule Dripio.Http.ZoneHandler do
  alias Dripio.Repo
  alias Dripio.Zone

  use Dripio.Http.Handler

  @permissions %{
    read: ["can_see_zone_details"],
    write: ["can_edit_zone_details"]
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
      with location_id <- :cowboy_req.binding(:location_id, req),
           zone_id <- :cowboy_req.binding(:zone_id, req),
           zone <-
             Zone.get(%{
               location_id: location_id,
               zone_id: zone_id
             }) do
        json =
          zone
          |> Zone.export()
          |> Jason.encode!()

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
      with location_id <- :cowboy_req.binding(:location_id, req),
           zone_id <- :cowboy_req.binding(:zone_id, req),
           {:ok, json, _} <- read_body(req),
           {:ok, zone_params} <- Jason.decode(json),
           zone <-
             Zone.get(%{
               location_id: location_id,
               zone_id: zone_id
             }) do
        changeset = Zone.change_zone(zone, zone_params)

        case Repo.update(changeset) do
          {:ok, _zone} ->
            :cowboy_req.reply(204, req)

          {:error, _changeset} ->
            :cowboy_req.reply(500, req)
        end

        {:stop, req, state}
      else
        _ ->
          req = :cowboy_req.reply(500, req)
          {:stop, req, state}
      end
    end
  end

  def delete_resource(req, state) do
    Trace.wrap do
      with location_id <- :cowboy_req.binding(:location_id, req),
           zone_id <- :cowboy_req.binding(:zone_id, req),
           zone <-
             Zone.get(%{
               location_id: location_id,
               zone_id: zone_id
             }) do
        case Repo.delete(zone) do
          {:ok, _zone} ->
            :cowboy_req.reply(200, req)

          _ ->
            :cowboy_req.reply(500, req)
        end

        {:stop, req, state}
      else
        _ ->
          req = :cowboy_req.reply(500, req)
          {:stop, req, state}
      end
    end
  end
end
