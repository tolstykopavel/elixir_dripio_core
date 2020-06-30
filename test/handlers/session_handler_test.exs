defmodule Dripio.Http.SessionHandler.Test do
  use ExUnit.Case
  use Dripio.Http.Test

  test "Can login" do
    user = %{
      email: "user@test.com",
      password: "SecretPassword123!@#"
    }

    assert {:ok, token} = login(user)
  end

  test "Can not login" do
    user = %{
      email: "user@test.com",
      password: "InvalidPassword"
    }

    assert :error = login(user)
  end

  test "Can not access private parts" do
    assert {:ok, {{_, 401, 'Unauthorized'}, _, _}} = http_req("/users", :get, [], nil)
  end

  test "Can access private parts if authorized" do
    user = %{
      email: "user@test.com",
      password: "SecretPassword123!@#"
    }
    {:ok, token} = login(user)

    assert {:ok, {{_, 200, 'OK'}, _, _}} =
      http_req("/users",
        :get,
        [{'authorization', :erlang.binary_to_list("Bearer #{token}")}],
        nil
      )
  end
end
