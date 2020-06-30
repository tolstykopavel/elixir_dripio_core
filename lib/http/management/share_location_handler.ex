defmodule Dripio.Http.ShareLocationHandler do
  alias Dripio.Repo
  alias Dripio.Location
  alias Dripio.User

  use Dripio.Http.Handler

  @permissions %{
    read: [],
    write: ["owner", "can_edit_location_details"]
  }

  def allowed_methods(req, state) do
    {["PATCH", "DELETE", "HEAD", "OPTIONS"], req, state}
  end

  def content_types_provided(req, state) do
    {[{"application/json", :to_json}], req, state}
  end

  def content_types_accepted(req, state) do
    {[{{"application", "json", :*}, :from_json}], req, state}
  end

  #

  def from_json(req, state) do
    Trace.wrap do
      with location_id <- :cowboy_req.binding(:location_id, req),
           {:ok, json, _} <- read_body(req),
           {:ok, %{"email" => email}} <- Jason.decode(json),
           {:ok, user} <- User.get_by_email(email) do
        changeset =
          Location.get_by_id(location_id)
          |> Location.share(user)

        case Repo.update(changeset) do
          {:ok, location} ->
            {:ok, updated_location_json} =
              location
              |> Repo.preload(:users)
              |> Location.export()
              |> Jason.encode()

            :cowboy_req.reply(204, %{}, updated_location_json, req)

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
           {:ok, json, _} <- read_body(req),
           {:ok, user} <-
             (case Jason.decode(json) do
                {:ok, %{"id" => id}} ->
                  User.get_by_id(id)

                {:ok, %{"email" => email}} ->
                  User.get_by_email(email)

                _ ->
                  {:error, :not_found}
              end) do
        changeset =
          Location.get_by_id(location_id)
          |> Location.unshare(user)

        case Repo.update(changeset) do
          {:ok, location} ->
            {:ok, updated_location_json} =
              location
              |> Repo.preload(:users)
              |> Location.export()
              |> Jason.encode()

            :cowboy_req.reply(204, %{}, updated_location_json, req)

          {:error, _changeset} ->
            :cowboy_req.reply(500, req)
        end
      else
        _ ->
          req = :cowboy_req.reply(500, req)
          {:stop, req, state}
      end
    end
  end
end
