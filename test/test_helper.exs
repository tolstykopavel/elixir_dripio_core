defmodule Dripio.Http.Test do
  defmacro __using__(_) do
    api_url = 'http://localhost:8085'

    quote do
      defp login(user) do
        {:ok, auth_json} = Jason.encode(user)

        case http_req("/session", :post, auth_json) do
          {:ok, {{_, 200, 'OK'}, _, body}} ->
            {:ok, %{"token" => token}} = Jason.decode(body)

            {:ok, token}

          error ->
            IO.inspect(error)
            :error
        end
      end

      defp http_req(url, method, body) do
        http_req(url, method, [], body)
      end

      defp http_req(url, :get, headers, _body) do
        :httpc.request(:get, {unquote(api_url) ++ :erlang.binary_to_list(url), headers}, [], [])
      end

      defp http_req(url, :delete, headers, _body) do
        :httpc.request(
          :delete,
          {unquote(api_url) ++ :erlang.binary_to_list(url), headers},
          [],
          []
        )
      end

      defp http_req(url, method, headers, body) do
        :httpc.request(
          method,
          {unquote(api_url) ++ :erlang.binary_to_list(url), headers, 'application/json',
           :erlang.binary_to_list(body)},
          [],
          []
        )
      end

      defp http_req(url, method, headers, type, body) do
        :httpc.request(
          method,
          {unquote(api_url) ++ :erlang.binary_to_list(url), headers, :erlang.binary_to_list(type),
           body},
          [],
          []
        )
      end

      defp format_multipart_formdata(boundary, field, file, data) do
        [
          "--#{boundary}",
          "Content-Disposition: form-data; name=\"#{field}\"; filename=\"#{file}\"",
          "Content-Type: application/octet-stream",
          "",
          "#{data}",
          "--#{boundary}--",
          ""
        ]
        |> Enum.join("\r\n")
      end
    end
  end
end

ExUnit.start()
