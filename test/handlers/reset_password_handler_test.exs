defmodule Dripio.Http.ResetPasswordHandler.Test do
  use ExUnit.Case

  use Dripio.Http.Test

  def get_reset_password_response do
    {:ok, {{_, 200, 'OK'}, _, body}} = http_req("/reset-password?email=user2@test.com",
                                          :get,
                                          [],
                                          nil
                                        )
    {:ok, json} = Jason.decode(body)
    json
  end

  test "Can reset password" do
    timeout = Application.get_env(:dripio_core, :reset_email_timeout)

    assert %{"success" => "ok"} = get_reset_password_response()

    :timer.sleep(1000)

    assert %{"timeout" => _} = get_reset_password_response()

    :timer.sleep(timeout * 1000)

    assert %{"success" => "ok"} = get_reset_password_response()

    :timer.sleep(timeout * 1000)

    assert true
  end
end
