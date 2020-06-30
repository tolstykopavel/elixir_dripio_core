defmodule Dripio.Http.ResetPasswordHandler do
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
      %{email: email} = :cowboy_req.match_qs([:email], req)

      resp = User.reset_password_and_send_email(%{"email" => email})

      {:ok, json} = Jason.encode(resp)

      {json, req, state}
    end
  end
end
