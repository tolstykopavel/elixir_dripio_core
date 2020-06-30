defmodule Dripio.Http.Handler do
  use Dripio.Trace

  @overridable [{:is_authorized, 2}]

  defmacro __using__(_opts) do
    quote location: :keep do
      require Dripio.Http.Handler
      use Dripio.Trace

      @before_compile unquote(__MODULE__)

      def init(req, state) do
        :ocp.with_child_span("Http handler #{unquote(__MODULE__)}")

        req =
          Trace.wrap "Set CORS Headers" do
            req =
              :cowboy_req.set_resp_header(
                "access-control-allow-headers",
                'content-type, authorization',
                req
              )

            # Access-Control-Allow-Methods
            req =
              :cowboy_req.set_resp_header(
                "access-control-allow-methods",
                'OPTIONS, POST, GET, PUT, PATCH, DELETE',
                req
              )

            req = :cowboy_req.set_resp_header("access-control-allow-origin", "*", req)
            req = :cowboy_req.set_resp_header("content-type", "application/json", req)
          end

        {:cowboy_rest, req, state}
      end

      def terminate(_reason, _request, _state) do
        :ocp.finish_span()
        :ok
      end

      defp read_body(req) do
        Trace.wrap do
          read_body(req, "")
        end
      end

      defp read_body(req, acc) do
        Trace.wrap do
          case :cowboy_req.read_body(req) do
            {:ok, data, req} -> {:ok, acc <> data, req}
            {:more, data, req} -> read_body(req, acc <> data)
          end
        end
      end
    end
  end

  defmacro __before_compile__(env) do
    for {fun, _arity} = el <- @overridable do
      unless Module.defines?(env.module, el) do
        apply(__MODULE__, fun, [env])
      end
    end
  end

  # default callbacks

  def is_authorized(_env) do
    required_perms =
      quote do
        @permissions || %{}
      end

    quote do
      def is_authorized(%{method: "OPTIONS"} = req, state) do
        Trace.wrap(do: {true, req, state})
      end

      def is_authorized(%{method: method} = req, state) do
        Trace.wrap do
          user_id = :cowboy_req.binding(:user_id, req)

          case :cowboy_req.header("authorization", req) do
            "Bearer " <> token ->
              {:ok, %{"perms" => perms, "sub" => current_user_id}} =
                Dripio.Http.Guardian.decode_and_verify(token)

              p_required = read_or_write_perms(unquote(required_perms), method)
              p_actual = list_intersection(p_required, perms)

              cond do
                Enum.empty?(p_required) ->
                  {true, req, state}

                user_id == current_user_id and
                    Enum.member?(p_required, "owner") ->
                  {true, req, state}

                not Enum.empty?(p_actual) ->
                  {true, req, state}

                true ->
                  {{false, "unauthorized"}, req, state}
              end

            _ ->
              {{false, "unauthorized"}, req, state}
          end
        end
      end

      def read_or_write_perms(required_perms, "POST"), do: Map.get(required_perms, :write, [])
      def read_or_write_perms(required_perms, "PUT"), do: Map.get(required_perms, :write, [])
      def read_or_write_perms(required_perms, "PATCH"), do: Map.get(required_perms, :write, [])
      def read_or_write_perms(required_perms, "DELETE"), do: Map.get(required_perms, :write, [])

      def read_or_write_perms(required_perms, "GET"), do: Map.get(required_perms, :read, [])
      def read_or_write_perms(required_perms, "HEAD"), do: Map.get(required_perms, :read, [])

      def list_intersection(list1, list2) when is_list(list1) and is_list(list2) do
        MapSet.intersection(Enum.into(list1, MapSet.new()), Enum.into(list2, MapSet.new()))
        |> MapSet.to_list()
      end

      def list_intersection(list1, list2) do
        []
      end
    end
  end

  def to_json do
    quote do
      def to_json(req, state) do
      end
    end
  end
end
