defmodule Dripio.Http.Webserver do
  def start_link() do
    start_server()
  end

  def start_server do
    {:ok, pid} =
      :cowboy.start_clear(:my_http_listener, [{:port, 8085}], %{
        env: %{dispatch: routes()},
        middlewares: [:opencensus_cowboy2_context, :cowboy_router, :cowboy_handler]
      })

    Process.register(pid, Dripio.Http.Webserver)
    {:ok, pid}
  end

  defp routes do
    :cowboy_router.compile([
      {:_,
       [
         {"/", Dripio.Http.PingHandler, []},
         {"/signup", Dripio.Http.SignupHandler, []},
         {"/users", Dripio.Http.UsersHandler, []},
         {"/users/:user_id", Dripio.Http.UserHandler, []},
         {"/me", Dripio.Http.CurrentUserHandler, []},
         {"/users/:user_id/locations", Dripio.Http.UserLocationsHandler, []},
         {"/users/:user_id/locations/:location_id", Dripio.Http.UserLocationHandler, []},
         {"/users/:user_id/locations/:location_id/share", Dripio.Http.ShareLocationHandler, []},
         {"/users/:user_id/locations/:location_id/devices", Dripio.Http.UserDevicesHandler, []},
         {"/users/:user_id/locations/:location_id/devices/:device_id",
          Dripio.Http.UserDeviceHandler, []},
         {"/users/:user_id/locations/:location_id/zones", Dripio.Http.UserZonesHandler, []},
         {"/users/:user_id/locations/:location_id/zones/:zone_id", Dripio.Http.UserZoneHandler,
          []},
         {"/locations", Dripio.Http.LocationsHandler, []},
         {"/locations/:location_id", Dripio.Http.LocationHandler, []},
         {"/locations/:location_id/share", Dripio.Http.ShareLocationHandler, []},
         {"/locations/:location_id/devices", Dripio.Http.DevicesHandler, []},
         {"/locations/:location_id/devices/:device_id", Dripio.Http.DeviceHandler, []},
         #
         {"/devices", Dripio.Http.DevicesHandler, []},
         {"/devices/:device_id", Dripio.Http.DeviceHandler, []},
         #
         {"/device-types", Dripio.Http.DeviceTypesHandler, []},
         {"/device-types/:type_id", Dripio.Http.DeviceTypeHandler, []},
         #
         {"/device-models", Dripio.Http.DeviceModelsHandler, []},
         {"/device-models/:model_id", Dripio.Http.DeviceModelHandler, []},
         #
         {"/software", Dripio.Http.DeviceModelSoftwaresHandler, []},
         {"/software/:software_id", Dripio.Http.DeviceModelSoftwareHandler, []},
         {"/ota/:model_id/", Dripio.Http.UploadSoftwareHandler, []},
         {"/ota/:model_id/:software_id", Dripio.Http.OtaHandler, []},
         #
         {"/send-email-confirmation/:user_id", Dripio.Http.SendEmailConfirmationHandler, []},
         {"/confirm-email", Dripio.Http.AcceptEmailConfirmationHandler, []},
         {"/reset-password", Dripio.Http.ResetPasswordHandler, []},
         {"/session", Dripio.Http.SessionHandler, []},
         {"/permissions", Dripio.Http.PermissionsHandler, []},
         #
         {"/websocket", Dripio.Http.WebsocketHandler, []}
       ]}
    ])
  end
end
