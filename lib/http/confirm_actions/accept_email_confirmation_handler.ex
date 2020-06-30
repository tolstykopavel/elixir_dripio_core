defmodule Dripio.Http.AcceptEmailConfirmationHandler do
  alias Dripio.Repo
  alias Dripio.User

  use Dripio.Http.Handler

  def allowed_methods(req, state) do
    {["GET", "HEAD", "OPTIONS"], req, state}
  end

  def content_types_provided(req, state) do
    {[{"application/json", :to_json}], req, state}
  end

  def is_authorized(req, state) do
    {true, req, state}
  end

  #

  def to_json(req, state) do
    Trace.wrap do
      with %{email: email, token: token} <- :cowboy_req.match_qs([:email, :token], req),
           {:ok, user} <- User.find_and_verify_confirmation_token(email, token) do
        user
        |> User.change_administration_fields(%{is_confirmed: true})
        |> Repo.update()

        {:ok, response_json} = Jason.encode(%{success: true})
        :cowboy_req.reply(200, %{}, response_json, req)
      else
        {:error, _error} ->
          {:ok, response_json} = Jason.encode(%{success: false})
          :cowboy_req.reply(401, %{}, response_json, req)
      end

      {:stop, req, state}
    end
  end
end
