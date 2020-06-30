defmodule Dripio.Http.ZonesHandler do
  alias Dripio.Repo
  alias Dripio.Zone

  @permissions %{
    read: ["can_see_zones"],
    write: ["can_edit_zones"]
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
      location_id = :cowboy_req.binding(:location_id, req)

      {:ok, json} =
        Zone.get_all(%{
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
      with location_id <- :cowboy_req.binding(:location_id, req),
           {:ok, json, _} <- read_body(req),
           {:ok, zone_params} <- Jason.decode(json) do
        changeset =
          Zone.create_zone(
            %Zone{},
            Map.put(zone_params, "location_id", location_id)
          )

        req =
          case Repo.insert(changeset) do
            {:ok, zone} ->
              json =
                zone
                |> Zone.export()
                |> Jason.encode!()

              :cowboy_req.reply(201, %{}, json, req)

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
end
