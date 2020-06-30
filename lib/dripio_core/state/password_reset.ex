defmodule DripioCore.State.PasswordReset do
  @moduledoc false

  alias Dripio.User

  def init do
    User.reset_all_tokens()

    %{
      module: __MODULE__,
      emails: %{},
      tokens: %{}
    }
  end

  def get(email, %{emails: emails}) do
    case Map.get(emails, email) do
      nil ->
        nil

      timestamp ->
        get_email_timeout_left(timestamp)
    end
  end

  def put(
        email,
        %{
          emails: emails,
          tokens: tokens
        } = state
      ) do
    emails =
      case Map.get(emails, email) do
        nil ->
          Map.put(emails, email, System.monotonic_time(:second))

        _timestamp ->
          emails
      end

    tokens =
      case Map.get(tokens, email) do
        nil ->
          Map.put(tokens, email, System.monotonic_time(:second))

        _timestamp ->
          tokens
      end

    state = Map.put(state, :emails, emails)
    Map.put(state, :tokens, tokens)
  end

  def validate(
        %{
          emails: emails,
          tokens: tokens
        } = state
      ) do
    emails =
      emails
      |> Enum.filter(fn {_k, timestamp} ->
        get_email_timeout_left(timestamp) > 0
      end)
      |> Enum.into(%{})

    tokens =
      tokens
      |> Enum.filter(fn {email, timestamp} ->
        to = get_token_timeout_left(timestamp) > 0

        unless to do
          User.reset_token(email)
        end

        to
      end)
      |> Enum.into(%{})

    state = Map.put(state, :emails, emails)
    Map.put(state, :tokens, tokens)
  end

  def validate(state) do
    state
  end

  def key() do
    :password_reset
  end

  #  ==========================================================================

  defp get_email_timeout_left(ts) do
    reset_timeout = Application.get_env(:dripio_core, :reset_email_timeout)
    reset_timeout - (System.monotonic_time(:second) - ts)
  end

  defp get_token_timeout_left(ts) do
    token_lifetime = Application.get_env(:dripio_core, :reset_token_lifetime)
    token_lifetime - (System.monotonic_time(:second) - ts)
  end
end
