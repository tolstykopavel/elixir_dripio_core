defmodule Dripio.ShareLocation.Test do
  use ExUnit.Case

  alias Dripio.Location
  alias Dripio.User
  alias Dripio.Repo

  test "share location" do
    location =
      Location.get_by_id("2661ef8c-1ee5-47f9-a7f9-debe77d79e9a")
      |> Repo.preload([:users])

    count1 = Enum.count(location.users)
    {:ok, user} = User.get_by_email("admin@test.com")

    refute Location.check_owner(user.id, location.id)

    ch =
      location
      |> Location.share(user)

    assert {:ok, _location} = Repo.update(ch)

    #

    location2 =
      Location.get_by_id("2661ef8c-1ee5-47f9-a7f9-debe77d79e9a")
      |> Repo.preload([:users])

    count2 = Enum.count(location2.users)

    assert count2 == count1 + 1
    assert List.last(location2.users).id == user.id
    assert Location.check_owner(user.id, location2.id)

    #

    ch =
      location2
      |> Location.unshare(user)

    assert {:ok, _} = Repo.update(ch)

    location3 =
      Location.get_by_id("2661ef8c-1ee5-47f9-a7f9-debe77d79e9a")
      |> Repo.preload([:users])

    count3 = Enum.count(location3.users)

    assert count3 == count2 - 1
    refute Location.check_owner(user.id, location3.id)
  end
end
