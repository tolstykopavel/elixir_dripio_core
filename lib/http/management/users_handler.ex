defmodule Dripio.Http.UsersHandler do
  alias Dripio.Repo
  alias Dripio.User

  use Dripio.Http.Handler

  @permissions %{
    read: ["can_see_users"],
    write: ["can_edit_users"]
  }
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
      {:ok, json} =
        Repo.all(User)
        |> Repo.preload(:locations)
        |> Enum.map(fn user -> User.export(user) end)
        |> Jason.encode()

      {json, req, state}
    end
  end

  def from_json(req, state) do
    Trace.wrap do
      {:ok, json, _} = read_body(req)
      {:ok, user_params} = Jason.decode(json)

      changeset = User.create_user(%User{}, user_params)

      req =
        case Repo.insert(changeset) do
          {:ok, user} ->
            unless user.is_confirmed do
              User.reset_user_confirmation_and_send_email(user_params)
            end

            {:ok, new_user_json} =
              user
              |> Repo.preload(:locations)
              |> User.export()
              |> Jason.encode()

            :cowboy_req.reply(201, %{}, new_user_json, req)

          {:error, _changeset} ->
            :cowboy_req.reply(500, req)
        end

      {:stop, req, state}
    end
  end
end
