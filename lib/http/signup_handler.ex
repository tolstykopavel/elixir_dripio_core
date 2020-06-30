defmodule Dripio.Http.SignupHandler do
  alias Dripio.Repo
  alias Dripio.User

  use Dripio.Http.Handler

  def allowed_methods(req, state) do
    {["PUT", "OPTIONS"], req, state}
  end

  def content_types_accepted(req, state) do
    {[{{"application", "json", :*}, :from_json}], req, state}
  end

  #

  def is_authorized(req, state) do
    {true, req, state}
  end

  def from_json(req, state) do
    Trace.wrap do
      with {:ok, json, _} <- read_body(req),
           {:ok, user_params} <- Jason.decode(json),
           "" = _ <- Map.get(user_params, "email", "") do
        changeset = User.change_user(%User{}, Map.put(user_params, "email", user_params["liame"]))

        req =
          case Repo.insert(changeset) do
            {:ok, user} ->
              User.reset_user_confirmation_and_send_email(%{"email" => user.email})
              :cowboy_req.reply(204, req)

            {:error, changeset} ->
              :cowboy_req.reply(500, req)
          end

        {:stop, req, state}
      else
        _ ->
          :cowboy_req.reply(500, req)
      end
    end
  end
end
