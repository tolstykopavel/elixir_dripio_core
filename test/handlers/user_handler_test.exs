defmodule Dripio.Http.UserHandler.Test do
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
             http_req(
               "/users",
               :get,
               [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
               nil
             )

    {:ok, [user | _]} = Jason.decode(body)

    %{user: user, token: token}
  end

  # =========================================================

  test "Load and update user data by id", %{user: user, token: token} do
    # load user data
    assert {:ok, {{_, 200, 'OK'}, _, body}} =
             http_req(
               "/users/" <> user["id"],
               :get,
               [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
               nil
             )

    {:ok, user_loaded} = Jason.decode(body)

    assert user == user_loaded

    # update some fields

    new_user_data =
      user_loaded
      |> Map.put("fname", "TestFname")
      |> Map.put("lname", "TestLname")

    {:ok, new_user_data_json} = Jason.encode(new_user_data)

    assert {:ok, {{_, 204, 'No Content'}, _, _}} =
             http_req(
               "/users/" <> user["id"],
               :patch,
               [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
               new_user_data_json
             )

    # load updated user

    assert {:ok, {{_, 200, 'OK'}, _, body}} =
             http_req(
               "/users/" <> user["id"],
               :get,
               [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
               nil
             )

    {:ok, updated_user} = Jason.decode(body)

    assert new_user_data == updated_user

    # restore old data

    {:ok, old_user_data_json} = Jason.encode(user)

    assert {:ok, {{_, 204, 'No Content'}, _, _}} =
             http_req(
               "/users/" <> user["id"],
               :patch,
               [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
               old_user_data_json
             )

    # load restored user

    assert {:ok, {{_, 200, 'OK'}, _, body}} =
             http_req(
               "/users/" <> user["id"],
               :get,
               [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
               nil
             )

    {:ok, restored_user} = Jason.decode(body)

    assert restored_user == user
  end
end
