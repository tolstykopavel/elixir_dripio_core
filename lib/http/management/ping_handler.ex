defmodule Dripio.Http.PingHandler do
  use Dripio.Http.Handler

  def allowed_methods(req, state) do
    {["GET", "HEAD", "OPTIONS"], req, state}
  end

  def content_types_provided(req, state) do
    {[{{"*", "*", :*}, :to_json}], req, state}
  end

  #

  def is_authorized(req, state) do
    {true, req, state}
  end

  def to_json(req, _state) do
    Trace.wrap do
      :cowboy_req.reply(200, req)
    end
  end
end
