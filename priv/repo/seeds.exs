# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Dripio.Repo.insert!(%Dripio.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Dripio.User
alias Dripio.Location
alias Dripio.Device
alias Dripio.DeviceModel
alias Dripio.DeviceType
alias Dripio.PeripheralType
alias Dripio.PeripheralModel

serials = [
  "DmXaTsRfbQJTQ3kzEWqSGj",
  "PjxyTDKBkZx6vAPdD6YptW",
  "vL4vQs7Sm3PyHWgEDgTXAG",
  "hGt7pFmbTDCmLuqxa9LJGX",
  "f4n9Su4hMgDMtg7GF8hhQH"
]
serials2 = [
  "zLko5UFpzLEPrP7soTe5jj",
  "unLpbzMBMYdD2ycHP6qrnY",
  "zvHh8xoJVS7p6BoozbFrYn",
  "f6srFer5qqSCvE3JWYDGcf",
  "eh67JvEecgGBA8YxWJySy3"
]

# User

admin =
  Dripio.Repo.insert!(
    %User{}
    |> User.create_user(%{
      email: "admin@test.com",
      fname: "Jane",
      lname: "Dodoe",
      password: "SecretPassword123!@#",
      avatar: "2"
    })
    |> User.change_administration_fields(%{
      is_confirmed: true,
      perms: Dripio.Permissions.all() |> Map.keys()
    })
  )

user =
  Dripio.Repo.insert!(
    %User{}
    |> User.create_user(%{
      email: "user@test.com",
      fname: "John",
      lname: "Doe",
      password: "SecretPassword123!@#",
      avatar: "1"
    })
    |> User.change_administration_fields(%{
      is_confirmed: true,
      perms: Dripio.Permissions.all() |> Map.keys()
    })
  )

user3 =
  Dripio.Repo.insert!(
    %User{}
    |> User.create_user(%{
      email: "user3@test.com",
      fname: "John3",
      lname: "Doe3",
      password: "SecretPassword123!@#3",
      avatar: "3"
    })
  )

user2 =
  Dripio.Repo.insert!(
    %User{}
    |> User.create_user(%{
      email: "user2@test.com",
      fname: "John2",
      lname: "Doe2",
      password: "SecretPassword123!@#2",
      avatar: "2"
    })
  )

des =
  Dripio.Repo.insert!(
    %User{}
    |> User.create_user(%{
      email: "des.binc@gmail.com",
      fname: "Eugene",
      lname: "Derevianko",
      password: "qweQWE123!@#",
      avatar: "1"
    })
    |> User.change_administration_fields(%{
      is_confirmed: true,
      perms: Dripio.Permissions.all() |> Map.keys()
    })
  )

alex =
  Dripio.Repo.insert!(
    %User{}
    |> User.create_user(%{
      email: "alex.business@gmail.com",
      fname: "Alex",
      lname: "Zehnbacht",
      password: "qweQWE123!@#",
      avatar: "1"
    })
    |> User.change_administration_fields(%{
      is_confirmed: true,
      perms: Dripio.Permissions.all() |> Map.keys()
    })
  )

# controller model and controller
device_type =
  Dripio.Repo.insert!(
    DeviceType.change_device_type(%DeviceType{}, %{
      "title" => "Smarthub 0.1 WiFi",
      "description" => "esp32"
    })
  )

device_model =
  Dripio.Repo.insert!(
    DeviceModel.change_device_model(%DeviceModel{}, %{
      "title" => "Model 0.1a",
      "description" => "very first alpha",
      "device_type_id" => device_type.id
    })
  )

des_location =
  Dripio.Repo.insert!(
    Location.create_location(%Location{}, %{
      "id" => "7vL9T9n2vK7wnp9QBgeGq8",
      "title" => "Des's Home Location",
      "owner_id" => des.id
    })
  )

alex_location =
  Dripio.Repo.insert!(
    Location.create_location(%Location{}, %{
      "id" => "LgQ8z5kdvpmaeamQRnmJzV",
      "title" => "Alex's Home Location",
      "owner_id" => alex.id
    })
  )

Enum.each(serials, fn id ->
  device =
    Dripio.Repo.insert!(
      Device.create_device(%Device{}, %{
        id: id,
        device_model_id: device_model.id,
        location_id: des_location.id
      })
    )

  # Units
  # Dripio.Repo.insert!(Unit.create_unit(%Unit{}, %{
  #   device_id: device.id,
  #   title: "valve",
  #   data: %{
  #     address: 12,
  #     io: 0,
  #     status: 0
  #   }
  # }))
  # Dripio.Repo.insert!(Unit.create_unit(%Unit{}, %{
  #   device_id: device.id,
  #   title: "flowmeter",
  #   data: %{
  #     address: 13,
  #     io: 1,
  #     status: 0,
  #     value: 100
  #   }
  # }))

  # peripherals
  peripheral_type =
    Dripio.Repo.insert!(
      PeripheralType.change_peripheral_type(%PeripheralType{}, %{
        "title" => "valve",
        "description" => "uart valve"
      })
    )

  peripheral_model =
    Dripio.Repo.insert!(
      PeripheralModel.change_peripheral_model(%PeripheralModel{}, %{
        "title" => "Model 0.1a",
        "description" => "very first alpha",
        "peripheral_type_id" => peripheral_type.id
      })
    )
end)

Enum.each(serials2, fn id ->
  device =
    Dripio.Repo.insert!(
      Device.create_device(%Device{}, %{
        id: id,
        device_model_id: device_model.id,
        location_id: alex_location.id
      })
    )

  # peripherals
  peripheral_type =
    Dripio.Repo.insert!(
      PeripheralType.change_peripheral_type(%PeripheralType{}, %{
        "title" => "valve",
        "description" => "uart valve"
      })
    )

  peripheral_model =
    Dripio.Repo.insert!(
      PeripheralModel.change_peripheral_model(%PeripheralModel{}, %{
        "title" => "Model 0.1a",
        "description" => "very first alpha",
        "peripheral_type_id" => peripheral_type.id
      })
    )
end)