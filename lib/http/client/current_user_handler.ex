defmodule Dripio.Http.CurrentUserHandler do
  alias Dripio.Repo
  alias Dripio.User

  use Dripio.Http.Handler

  @permissions %{}

  def allowed_methods(req, state) do
    {["GET", "PATCH", "HEAD", "OPTIONS"], req, state}
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
      "Bearer " <> token = :cowboy_req.header("authorization", req)

      {:ok, user, _claims} = Dripio.Http.Guardian.resource_from_token(token)

      {:ok, json} =
        user
        |> Repo.preload(:locations)
        |> User.export()
        |> Jason.encode()

      {json, req, state}
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      {:ok, json, _} = read_body(req)
      {:ok, user_params} = Jason.decode(json)

      "Bearer " <> token = :cowboy_req.header("authorization", req)

      {:ok, old_user, _claims} = Dripio.Http.Guardian.resource_from_token(token)

      changeset =
        old_user
        |> User.change_user(user_params)

      case Repo.update(changeset) do
        {:ok, user} ->
          if old_user.is_confirmed && !user.is_confirmed do
            User.reset_user_confirmation_and_send_email(%{"email" => user.email})
          end

          :cowboy_req.reply(204, req)

        {:error, _changeset} ->
          :cowboy_req.reply(500, req)
      end

      {:stop, req, state}
    end
  end
end
