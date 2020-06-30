defmodule Dripio.Http.UsersHandler.Test do
  use ExUnit.Case
  use Dripio.Http.Test

  test "Loads all users list" do
    user = %{
      email: "user@test.com",
      password: "SecretPassword123!@#"
    }
    {:ok, token} = login(user)

    assert {:ok, {{_, 200, 'OK'}, _, body}} =
      http_req("/users",
        :get,
        [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
        nil
      )

    {:ok, users} = Jason.decode(body)

    assert [%{
              "id" => _,
              "email" => _,
              "fname" => _,
              "lname" => _,
              "avatar" => _,
              "locations" => _,
              "is_confirmed" => _,
              "perms" => _,
            } | _] = users
  end

  test "Create new user and delete it" do
    user = %{
      email: "user@test.com",
      password: "SecretPassword123!@#"
    }
    {:ok, token} = login(user)

    user_data = %{
      "email" => "user_handler_test_email@dripio.com",
      "fname" => "hello",
      "lname" => "world",
      "avatar" => "qwerty",
      "phone" => "+71234567890"
    }

    {:ok, user_data_json} = Jason.encode(Map.merge(user_data, %{"password" => "SecretPassword!@#123"}))
    assert {:ok, {{_, 201, 'Created'}, _, body}} =
      http_req("/users",
        :put,
        [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
        user_data_json
      )

    {:ok, created_user} = Jason.decode(body)

    assert Map.equal?(user_data, Map.take(created_user, Map.keys(user_data)))

    assert {:ok, {{_, 200, 'OK'}, _, _}} =
      http_req("/users/" <> created_user["id"],
        :delete,
        [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
        nil
      )
  end
end
