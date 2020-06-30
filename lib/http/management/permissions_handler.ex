defmodule Dripio.Http.PermissionsHandler do
  alias Dripio.Permissions

  use Dripio.Http.Handler

  @permissions %{}

  def allowed_methods(req, state) do
    {["GET", "HEAD", "OPTIONS"], req, state}
  end

  def content_types_provided(req, state) do
    {[{"application/json", :to_json}], req, state}
  end

  #

  def to_json(req, state) do
    Trace.wrap do
      {:ok, json} =
        Permissions.all()
        |> Jason.encode()

      {json, req, state}
    end
  end
end
