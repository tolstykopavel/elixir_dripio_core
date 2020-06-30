defmodule Dripio.Http.UserLocationHandler do
  alias Dripio.Repo
  alias Dripio.Location

  use Dripio.Http.Handler

  @permissions %{
    read: ["owner", "can_see_location_details"],
    write: ["owner", "can_edit_location_details"]
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

      if Location.check_owner(user_id, location_id) do
        location = Location.get_by_id(location_id) |> Repo.preload(:users)

        {:ok, json} =
          location
          |> Location.export()
          |> Jason.encode()

        {json, req, state}
      else
        :cowboy_req.reply(404, req)
        {:stop, req, state}
      end
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      location_id = :cowboy_req.binding(:location_id, req)

      {:ok, json, _} = read_body(req)
      {:ok, location_params} = Jason.decode(json)

      changeset =
        Location.get_by_id(location_id)
        |> Location.change_location(location_params)

      case Repo.update(changeset) do
        {:ok, _location} ->
          :cowboy_req.reply(204, req)

        {:error, _changeset} ->
          :cowboy_req.reply(500, req)
      end

      {:stop, req, state}
    end
  end

  def delete_resource(req, state) do
    Trace.wrap do
      location_id = :cowboy_req.binding(:location_id, req)
      location = Location.get_by_id(location_id)

      case Repo.delete(location) do
        {:ok, _location} ->
          :cowboy_req.reply(200, req)

        {:error, _changeset} ->
          :cowboy_req.reply(500, req)
      end

      {:stop, req, state}
    end
  end
end
