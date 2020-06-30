defmodule Dripio.Http.DeviceModelSoftwaresHandler do
  alias Dripio.DeviceSoftware
  alias Dripio.Repo

  @permissions %{
    read: ["can_see_device_softwares"],
    write: ["can_edit_device_softwares"]
  }
  use Dripio.Http.Handler

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
        DeviceSoftware.get()
        |> Enum.map(fn sw -> DeviceSoftware.export(sw) end)
        |> Jason.encode()

      {json, req, state}
    end
  end
end
