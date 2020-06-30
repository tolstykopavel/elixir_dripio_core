defmodule Dripio.Zone.Test do
  use ExUnit.Case

  alias Dripio.Zone
  alias Dripio.Repo

  @location_id "2661ef8c-1ee5-47f9-a7f9-debe77d79e9a"

  setup do
    chs =
      Zone.create_zone(%Zone{}, %{
        location_id: @location_id,
        title: "root"
      })

    IO.inspect(" == before == ")
    {:ok, root_zone} = Repo.insert(chs)

    IO.inspect(root_zone)

    chs1 =
      Zone.create_zone(%Zone{}, %{
        location_id: @location_id,
        title: "child1",
        parent_id: root_zone.id
      })

    {:ok, child_zone1} = Repo.insert(chs1)

    IO.inspect(child_zone1)

    chs2 =
      Zone.create_zone(%Zone{}, %{
        location_id: @location_id,
        title: "child2",
        parent_id: child_zone1.id
      })

    {:ok, child_zone2} = Repo.insert(chs2)

    IO.inspect(child_zone2)
    IO.inspect(" ==  == ")

    %{
      root: root_zone,
      child1: child_zone1,
      child2: child_zone2
    }
  end

  test "access to zone by id", q = %{root: root, child1: child1, child2: child2} do
    assert rz = Zone.get(%{zone_id: root.id})
    assert cz1 = Zone.get(%{zone_id: child1.id})
    assert cz2 = Zone.get(%{zone_id: child2.id})

    rz_id = rz.id
    cz1_id = cz1.id

    assert %{
             id: _,
             title: _,
             parent_id: nil,
             location_id: @location_id
           } = rz

    assert %{
             id: _,
             title: _,
             parent_id: ^rz_id,
             location_id: @location_id
           } = cz1

    assert %{
             id: _,
             title: _,
             parent_id: ^cz1_id,
             location_id: @location_id
           } = cz2
  end
end
