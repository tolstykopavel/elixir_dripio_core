defmodule Dripio.Http.CurrentUserHandler.Test do
  use ExUnit.Case
  use Dripio.Http.Test

  setup do
    # first we need to authorize and load list of all available users to get a valid id
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

    {:ok, [user | _]} = Jason.decode(body)

    %{user: user, token: token}
  end

  # =========================================================

  test "Get and update current user", %{user: user, token: token} do
    #
    assert {:ok, {{_, 200, 'OK'}, _, old_user_data_json}} =
      http_req("/me",
        :get,
        [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
        nil
      )

    {:ok, old_user_data} = Jason.decode(old_user_data_json)

    assert old_user_data["email"] == "user@test.com"

    #

    new_user_data = %{
      "fname" => "TestFname",
      "lname" => "TestLname"
    }
    {:ok, new_user_data_json} = Jason.encode(new_user_data)

    #
    assert {:ok, {{_, 204, _}, _, _}} =
      http_req("/me",
        :patch,
        [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
        new_user_data_json
      )

    #

    assert {:ok, {{_, 200, 'OK'}, _, body}} =
      http_req("/me",
        :get,
        [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
        nil
      )

    {:ok, %{
      "fname" => "TestFname",
      "lname" => "TestLname"
    }} = Jason.decode(body)

    #

    {:ok, old_user_data_json} = Jason.encode(old_user_data)
    assert {:ok, {{_, 204, _}, _, _}} =
      http_req("/me",
        :patch,
        [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
        old_user_data_json
      )
  end
end
