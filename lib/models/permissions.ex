defmodule Dripio.Permissions do
  def all do
    %{
      "can_see_users" => "Can see users list",
      "can_edit_users" => "Can create new users",
      "can_see_user_details" => "Can see user details",
      "can_edit_user_details" => "Can edit user details, change perms, etc.",
      "can_see_locations" => "Can see global locations list",
      "can_edit_locations" => "Can create new locations",
      "can_see_location_details" => "Can see any location's details",
      "can_edit_location_details" => "Can edit any location",
      "can_see_devices" => "Can see global devices list",
      "can_edit_devices" => "Cancreate new devices",
      "can_see_device_details" => "Can see device details and output data",
      "can_edit_device_details" => "Can edit device properties and send commands",
      "can_see_device_softwares" => "Can see available software versions",
      "can_edit_device_softwares" => "Can add new software",
      "can_see_device_types" => "Can see device types",
      "can_edit_device_types" => "Can edit device types",
      "can_see_device_models" => "Can see device models",
      "can_edit_device_models" => "Can edit device models",
      "can_send_email_confirmation" => "Can send email confirmation to any user"
    }
  end
end
