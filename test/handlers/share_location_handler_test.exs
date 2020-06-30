defmodule Dripio.Http.ShareLocationHandler.Test do
  use ExUnit.Case
  use Dripio.Http.Test

  setup do
    # first we need to authorize and load list of all available users to get a valid id
    user = %{
      email: "admin@test.com",
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

  test "can share location", %{user: user, token: token} do
    #
    assert {:ok, {{_, 204, _}, _, _}} =
             http_req(
               "/locations/2661ef8c-1ee5-47f9-a7f9-debe77d79e9a/share",
               :patch,
               [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
               Jason.encode!(%{
                 "email" => "user@test.com"
               })
             )
  end
end
