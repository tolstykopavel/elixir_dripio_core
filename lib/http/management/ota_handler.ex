defmodule Dripio.Http.OtaHandler do
  alias Dripio.DeviceSoftware
  alias Dripio.Repo

  @permissions %{}
  use Dripio.Http.Handler

  def allowed_methods(req, state) do
    {["GET", "HEAD", "OPTIONS"], req, state}
  end

  def content_types_provided(req, state) do
    {[{"application/octet-stream", :to_stream}], req, state}
  end

  #

  def is_authorized(req, state) do
    {true, req, state}
  end

  def to_stream(req, state) do
    Trace.wrap do
      with software_id <- :cowboy_req.binding(:software_id, req) do
        sw = DeviceSoftware.get_by_id(software_id)

        req =
          :cowboy_req.reply(
            200,
            %{
              "Content-Disposition" =>
                "attachment; filename=\"dripio-smarthub-firmware-#{sw.device_model_id}-#{sw.id}.bin\""
            },
            sw.bin,
            req
          )

        {:stop, req, state}
      else
        _ ->
          req = :cowboy_req.reply(500, req)
          {:stop, req, state}
      end
    end
  end
end
