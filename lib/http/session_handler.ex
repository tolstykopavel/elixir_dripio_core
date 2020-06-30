defmodule Dripio.Http.SessionHandler do
  alias Dripio.User

  use Dripio.Http.Handler

  def allowed_methods(req, state) do
    {["POST", "OPTIONS"], req, state}
  end

  def content_types_accepted(req, state) do
    {[
       {"application/json", :undefined}
     ], req, state}
  end

  #

  def is_authorized(%{method: "OPTIONS"} = req, state) do
    {true, req, state}
  end

  def is_authorized(req, state) do
    {:ok, json, _} = read_body(req)
    {:ok, auth_params} = Jason.decode(json)

    req =
      case User.find_and_verify(auth_params) do
        {:ok, user} ->
          {:ok, token, claims} =
            Dripio.Http.Guardian.encode_and_sign(user, perms: User.get_perms(user))

          exp = Map.get(claims, "exp")

          {:ok, response_json} = Jason.encode(%{token: token, exp: exp})

          :cowboy_req.reply(200, %{}, response_json, req)

        {:error, _error} ->
          :cowboy_req.reply(401, req)
      end

    {:stop, req, state}
  end
end
