defmodule Dripio.Http.SendEmailConfirmationHandler do
  alias Dripio.User

  use Dripio.Http.Handler

  @permissions %{
    read: ["owner", "can_send_email_confirmation"]
  }

  def allowed_methods(req, state) do
    {["GET", "HEAD", "OPTIONS"], req, state}
  end

  def content_types_provided(req, state) do
    {[{"application/json", :to_json}], req, state}
  end

  #

  def to_json(req, state) do
    Trace.wrap do
      with user_id <- :cowboy_req.binding(:user_id, req),
           {:ok, user} <- User.get_by_id(user_id),
           resp = User.reset_user_confirmation_and_send_email(user),
           {:ok, json} = Jason.encode(resp) do
        {json, req, state}
      else
        _ ->
          :cowboy_req.reply(404, req)
          {:stop, req, state}
      end
    end
  end
end
