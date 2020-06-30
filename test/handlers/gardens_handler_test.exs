defmodule Dripio.Http.LocationsHandler.Test do
  use ExUnit.Case
  use Dripio.Http.Test

  @admin %{
    email: "admin@test.com",
    password: "SecretPassword123!@#"
  }
  @simple_user %{
    email: "user3@test.com",
    password: "SecretPassword123!@#3"
  }

  setup do
    {:ok, admin_token} = login(@admin)
    {:ok, simple_user_token} = login(@simple_user)

    %{
      admin_header: {'authorization', :erlang.binary_to_list("Bearer #{admin_token}")},
      user_header: {'authorization', :erlang.binary_to_list("Bearer #{simple_user_token}")}
    }
  end

  test "Loads all locations list", %{admin_header: admin_header} do
    assert {:ok, {{_, 200, 'OK'}, _, body}} = http_req("/locations", :get, [admin_header], nil)

    {:ok, locations} = Jason.decode(body)

    assert [
             %{
               "id" => _,
               "title" => _,
               "address" => _,
               "picture" => _,
               "auth_key" => _,
               "owner_user_id" => _,
               "users" => _
             }
             | _
           ] = locations
  end

  test "Store location address as object", %{admin_header: admin_header} do
    {:ok, {{_, 200, 'OK'}, _, body}} = http_req("/locations", :get, [admin_header], nil)
    [location | _] = Jason.decode!(body)

    location_id = location["id"]

    new_address = %{
      "city" => "Bryansk",
      "address" => "Moskovsky micro-district"
    }

    assert {:ok, {{_, 204, _}, _, _}} =
             http_req(
               "/locations/#{location_id}",
               :patch,
               [admin_header],
               Jason.encode!(%{
                 "address" => new_address
               })
             )

    assert {:ok, {{_, 200, 'OK'}, _, body}} =
             http_req("/locations/#{location_id}", :get, [admin_header], nil)

    %{"address" => address} = Jason.decode!(body)

    assert ^new_address = address
  end

  test "Fail to load all locations list because of perms", %{user_header: user_header} do
    assert {:ok, {{_, 401, _}, _, body}} = http_req("/locations", :get, [user_header], nil)
  end
end
