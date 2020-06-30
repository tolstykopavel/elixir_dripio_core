defmodule Dripio.Http.ModelSoftwaresHandler.Test do
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

    admin_header = {'authorization', :erlang.binary_to_list("Bearer #{admin_token}")}
    user_header = {'authorization', :erlang.binary_to_list("Bearer #{simple_user_token}")}

    {:ok, {{_, 200, 'OK'}, _, body}} = http_req("/device-models", :get, [admin_header], nil)

    device_models = Jason.decode!(body)

    %{
      admin_header: admin_header,
      user_header: user_header,
      device_models: device_models
    }
  end

  #

  test "Can post new software", %{
    admin_header: admin_header,
    device_models: [dm | _]
  } do
    {:ok, f} =
      :file.read_file(:erlang.binary_to_list("#{:code.priv_dir(:dripio_core)}/firmware.bin"))

    # = :erlang.binary_to_list(f)
    data = f
    boundary = "----WebKitFormBoundary2TFJHlvgMepDPqge"

    req_body = "--#{boundary}
Content-Disposition: form-data; name=\"firmware.bin\"; filename=\"firmware.bin\"
Content-Type: application/octet-stream

" <> data <> "
--#{boundary}--
"

    content_type = "multipart/form-data; boundary=#{boundary}"
    req_header = {'Content-Length', :erlang.integer_to_list(byte_size(req_body))}

    # assert {:ok, {{_, 200, 'OK'}, _, body}} =
    IO.inspect("--")

    res =
      http_req(
        "/device-models/#{dm["id"]}/software",
        :post,
        [admin_header, req_header],
        # [],
        content_type,
        :erlang.binary_to_list(req_body)
      )

    IO.inspect(res)
    IO.inspect("--")
  end

  test "Can get available software list", %{
    admin_header: admin_header,
    device_models: [dm | _]
  } do
    assert {:ok, {{_, 200, 'OK'}, _, body}} =
             http_req("/device-models/#{dm["id"]}/software", :get, [admin_header], nil)

    softwares = Jason.decode!(body)
    assert is_list(softwares)
  end

  # httpc:request(post,{Url, [],"multipart/form-data", F},[],[])
end
