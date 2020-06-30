defmodule Dripio.Http.UploadSoftwareHandler do
  alias Dripio.DeviceSoftware
  alias Dripio.Repo

  @permissions %{
    read: [],
    write: ["can_edit_device_softwares"]
  }
  use Dripio.Http.Handler

  def allowed_methods(req, state) do
    {["HEAD", "POST", "OPTIONS"], req, state}
  end

  def content_types_accepted(req, state) do
    {[{"multipart/form-data", :from_json}], req, state}
  end

  #

  def from_json(req, state) do
    Trace.wrap do
      with model_id <- :cowboy_req.binding(:model_id, req),
           {:ok, headers, req} <- :cowboy_req.read_part(req),
           {:ok, data, req} <- :cowboy_req.read_part_body(req),
           {:file, _, fileName, contentType} <- :cow_multipart.form_data(headers) do
        changeset =
          DeviceSoftware.create_software(
            %DeviceSoftware{},
            %{
              "version" => String.split(fileName, ".") |> List.first(),
              "device_model_id" => model_id,
              "bin" => data,
              "description" => fileName
            }
          )

        req =
          case Repo.insert(changeset) do
            {:ok, sw} ->
              {:ok, new_software_json} =
                sw
                |> DeviceSoftware.export()
                |> Jason.encode()

              :cowboy_req.reply(201, %{}, new_software_json, req)

            {:error, _changeset} ->
              :cowboy_req.reply(500, req)
          end

        {:stop, req, state}
      else
        _ ->
          req = :cowboy_req.reply(500, req)
          {:stop, req, state}
      end
    end
  end
end
