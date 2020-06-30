defmodule Dripio.Http.UserHandler do
  alias Dripio.Repo
  alias Dripio.User

  use Dripio.Http.Handler

  @permissions %{
    read: ["can_see_user_details"],
    write: ["can_edit_user_details"]
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
      with user_id <- :cowboy_req.binding(:user_id, req),
           {:ok, user} <- User.get_by_id(user_id) do
        {:ok, json} =
          user
          |> Repo.preload(:locations)
          |> User.export()
          |> Jason.encode()

        {json, req, state}
      else
        _ ->
          :cowboy_req.reply(404, req)
          {:stop, req, state}
      end
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      with user_id <- :cowboy_req.binding(:user_id, req),
           {:ok, user} <- User.get_by_id(user_id),
           {:ok, json, _} <- read_body(req),
           {:ok, user_params} <- Jason.decode(json) do
        changeset =
          user
          |> User.change_user(user_params)
          |> User.change_administration_fields(user_params)

        case Repo.update(changeset) do
          {:ok, user} ->
            unless user.is_confirmed do
              User.reset_user_confirmation_and_send_email(%{"email" => user.email})
            end

            :cowboy_req.reply(204, req)

          {:error, _changeset} ->
            :cowboy_req.reply(500, req)
        end

        {:stop, req, state}
      else
        _ ->
          :cowboy_req.reply(500, req)
          {:stop, req, state}
      end
    end
  end

  def delete_resource(req, state) do
    Trace.wrap do
      with user_id <- :cowboy_req.binding(:user_id, req),
           {:ok, user} <- User.get_by_id(user_id) do
        case Repo.delete(user) do
          {:ok, _user} ->
            :cowboy_req.reply(200, req)

          {:error, _changeset} ->
            :cowboy_req.reply(500, req)
        end

        {:stop, req, state}
      else
        _ ->
          :cowboy_req.reply(500, req)
          {:stop, req, state}
      end
    end
  end
end
