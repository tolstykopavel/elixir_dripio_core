defmodule Dripio.User do
  import Ecto.Query
  import Ecto.Changeset
  use Ecto.Schema
  use Dripio.Trace

  alias Dripio.Repo
  alias Dripio.User
  alias Dripio.Mailer
  alias Dripio.Email

  alias DripioCore.State

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "users" do
    field(:email, :string)
    field(:fname, :string, default: "")
    field(:lname, :string, default: "")
    field(:avatar, :string)
    field(:phone, :string)
    field(:notes, :string)
    field(:perms, {:array, :string}, default: [])
    field(:is_confirmed, :boolean, default: false)

    field(:password_hash, :string)
    field(:password, :string, virtual: true)

    field(:security_token, :string)
    field(:confirmation_token, :string)

    many_to_many(:locations, Dripio.Location,
      join_through: "users_locations",
      on_delete: :delete_all
    )

    timestamps()
  end

  # changesets

  def change_user(model, params \\ :empty) do
    Trace.wrap do
      model
      |> cast(params, [:email, :fname, :lname, :avatar, :phone, :notes])
      |> unique_constraint(:email)
      |> validate_format(:email, ~r/@/)
      |> need_send_email_confirmation
      |> set_password(params)
    end
  end

  def set_password(model, params \\ :empty) do
    Trace.wrap do
      model
      |> cast(params, [:password])
      |> hash_password(params)
    end
  end

  def create_user(model, params \\ :empty) do
    Trace.wrap do
      model
      |> change_user(params)
      |> set_password(params)
      |> validate_required(:email)
      |> put_default_perms
    end
  end

  def change_administration_fields(model, params \\ :empty) do
    Trace.wrap do
      model
      |> cast(params, [:perms, :is_confirmed])
    end
  end

  defp hash_password(changeset, _params) do
    Trace.wrap do
      case changeset do
        %Ecto.Changeset{changes: %{password: _password}} ->
          changeset
          |> validate_length(:password, min: 10)
          |> validate_format(:password, ~r/[A-Z0-9!@#$%^&*()_+=_~`]/)
          |> put_password_hash

        _ ->
          changeset
      end
    end
  end

  # // changesets

  def find_and_verify(%{"email" => email, "password" => password}) do
    Trace.wrap do
      with {:ok, user} <- get_by_email(email),
           true <- verify_password(user, password) do
        {:ok, user}
      else
        _ -> {:error, :invalid_credentials}
      end
    end
  end

  def find_and_verify(%{"email" => email, "token" => token}) do
    Trace.wrap do
      with {:ok, user} <- get_by_email(email),
           true <- verify_token(user, token) do
        {:ok, user}
      else
        _ -> {:error, :invalid_token}
      end
    end
  end

  def find_and_verify_confirmation_token(email, token) do
    Trace.wrap do
      with {:ok, user} <- get_by_email(email),
           true <- verify_confirmation_token(user, token) do
        {:ok, user}
      else
        _ -> {:error, :invalid_token}
      end
    end
  end

  def reset_password(%{"email" => email}) do
    Trace.wrap do
      with {token, token_hash} <- make_token(),
           {:ok, user} <- get_by_email(email) do
        User
        |> where(email: ^user.email)
        |> update(set: [password_hash: "", security_token: ^token_hash])
        |> Repo.update_all([])

        {user, token}
      else
        error -> {:error, error}
      end
    end
  end

  def reset_confirmation(%{"email" => email}) do
    Trace.wrap do
      with {token, token_hash} <- make_token(),
           {:ok, user} <- get_by_email(email) do
        User
        |> where(email: ^user.email)
        |> update(set: [is_confirmed: false, confirmation_token: ^token_hash])
        |> Repo.update_all([])

        {user, token}
      else
        _ -> nil
      end
    end
  end

  def reset_all_tokens() do
    Trace.wrap do
      Repo.update_all(User, set: [security_token: nil])
    end
  end

  def reset_token(%{"email" => email}) do
    reset_token(email)
  end

  def reset_token(email) do
    Trace.wrap do
      user = get_by_email(email)

      case user do
        nil ->
          nil

        _ ->
          User
          |> where(email: ^user.email)
          |> update(set: [security_token: nil])
          |> Repo.update_all([])

          user
      end
    end
  end

  def reset_confirmation_token(%{"email" => email}) do
    reset_confirmation_token(email)
  end

  def reset_confirmation_token(email) do
    Trace.wrap do
      user = get_by_email(email)

      case user do
        nil ->
          nil

        _ ->
          User
          |> where(email: ^user.email)
          |> update(set: [confirmation_token: nil])
          |> Repo.update_all([])

          user
      end
    end
  end

  #

  defp get_reset_password_timeout(%{"email" => email}) do
    Trace.wrap do
      State.get_value(DripioCore.State.PasswordReset, email)
    end
  end

  defp put_reset_password_timeout(%{"email" => email}) do
    Trace.wrap do
      State.put_value(DripioCore.State.PasswordReset, email)
    end
  end

  defp get_resend_confirmation_timeout(%{"email" => email}) do
    Trace.wrap do
      State.get_value(DripioCore.State.AccountConfirmation, email)
    end
  end

  defp put_resend_confirmation_timeout(%{"email" => email}) do
    Trace.wrap do
      State.put_value(DripioCore.State.AccountConfirmation, email)
    end
  end

  #

  def reset_password_and_send_email(user_params) do
    Trace.wrap do
      case get_reset_password_timeout(user_params) do
        nil ->
          case User.reset_password(user_params) do
            nil ->
              nil

            {user, token} ->
              site_url = Application.get_env(:dripio_core, :site_url)
              link = "#{site_url}/#/password-recovery?email=#{user.email}&token=#{token}"

              Email.reset_password(user, link)
              |> Mailer.deliver_later()
          end

          put_reset_password_timeout(user_params)

          %{success: :ok}

        val ->
          %{timeout: val}
      end
    end
  end

  def reset_user_confirmation_and_send_email(%Dripio.User{} = user) do
    reset_user_confirmation_and_send_email(%{"email" => user.email})
  end

  def reset_user_confirmation_and_send_email(user_params) do
    Trace.wrap do
      case get_resend_confirmation_timeout(user_params) do
        nil ->
          case reset_confirmation(user_params) do
            nil ->
              nil

            {user, token} ->
              send_user_registration(user, token)
          end

          put_resend_confirmation_timeout(user_params)

          %{success: :ok}

        val ->
          %{timeout: val}
      end
    end
  end

  #

  def send_user_registration(user, token) do
    Trace.wrap do
      site_url = Application.get_env(:dripio_core, :site_url)
      link = "#{site_url}/#/email-confirmation?email=#{user.email}&token=#{token}"

      Email.user_registration(user, link)
      |> Mailer.deliver_later()

      :ok
    end
  end

  def send_user_confirmation(user, token) do
    Trace.wrap do
      site_url = Application.get_env(:dripio_core, :site_url)
      link = "#{site_url}/#/email-confirmation?email=#{user.email}&token=#{token}"

      Email.email_confirmation(user, link)
      |> Mailer.deliver_later()

      :ok
    end
  end

  # private

  defp make_token() do
    Trace.wrap do
      token_bytes = :crypto.strong_rand_bytes(32)
      token = Base.encode16(token_bytes)
      token_hash = Bcrypt.hash_pwd_salt(token_bytes)
      {token, token_hash}
    end
  end

  defp need_send_email_confirmation(changeset) do
    Trace.wrap do
      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{email: _email}} ->
          put_change(changeset, :is_confirmed, false)

        _ ->
          changeset
      end
    end
  end

  defp put_password_hash(changeset) do
    Trace.wrap do
      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
          put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(pass))

        _ ->
          changeset
      end
    end
  end

  defp put_default_perms(changeset) do
    Trace.wrap do
      case changeset do
        %Ecto.Changeset{} ->
          put_change(changeset, :perms, [])

        _ ->
          changeset
      end
    end
  end

  def get_by_email(email) do
    Trace.wrap do
      case Repo.get_by(User, email: email) do
        nil -> {:error, :not_found}
        user -> {:ok, user}
      end
    end
  end

  def get_by_id(id) do
    Trace.wrap do
      case Repo.get(User, id) do
        nil -> {:error, :not_found}
        user -> {:ok, user}
      end
    end
  end

  def verify_confirmation(user) do
    Trace.wrap do
      user.is_confirmed
    end
  end

  #
  defp verify_password(nil, _) do
    Trace.wrap do
      Comeonin.Bcrypt.dummy_checkpw()
    end
  end

  defp verify_password(%{password_hash: ""}, _) do
    Trace.wrap do
      Comeonin.Bcrypt.dummy_checkpw()
    end
  end

  defp verify_password(client, password) do
    Trace.wrap do
      Bcrypt.verify_pass(password, client.password_hash)
    end
  end

  #
  defp verify_token(nil, _) do
    Trace.wrap do
      Comeonin.Bcrypt.dummy_checkpw()
    end
  end

  defp verify_token(%{security_token: ""}, _) do
    Trace.wrap do
      Comeonin.Bcrypt.dummy_checkpw()
    end
  end

  defp verify_token(user, token) do
    Trace.wrap do
      case Base.decode16(token) do
        {:ok, token} ->
          case Bcrypt.verify_pass(token, user.security_token) do
            true ->
              User
              |> where(email: ^user.email)
              |> update(
                set: [
                  password_hash: "",
                  security_token: "",
                  confirmation_token: "",
                  is_confirmed: true
                ]
              )
              |> Repo.update_all([])

              true

            false ->
              false
          end

        _ ->
          Comeonin.Bcrypt.dummy_checkpw()
      end
    end
  end

  #
  defp verify_confirmation_token(nil, _) do
    Trace.wrap do
      Comeonin.Bcrypt.dummy_checkpw()
    end
  end

  defp verify_confirmation_token(%{confirmation_token: ""}, _) do
    Trace.wrap do
      Comeonin.Bcrypt.dummy_checkpw()
    end
  end

  defp verify_confirmation_token(user, token) do
    Trace.wrap do
      case Base.decode16(token) do
        {:ok, token} ->
          case Bcrypt.verify_pass(token, user.confirmation_token) do
            true ->
              User
              |> where(email: ^user.email)
              |> update(set: [is_confirmed: true, confirmation_token: ""])
              |> Repo.update_all([])

              true

            false ->
              false
          end

        _ ->
          Comeonin.Bcrypt.dummy_checkpw()
      end
    end
  end

  def get_perms(model) do
    Trace.wrap do
      Enum.map(model.perms, fn p -> String.to_atom(p) end)
    end
  end

  #

  def export(user) do
    %{
      id: user.id,
      email: user.email,
      fname: user.fname,
      lname: user.lname,
      avatar: user.avatar,
      phone: user.phone,
      notes: user.notes,
      perms: user.perms,
      is_confirmed: user.is_confirmed,
      locations: Enum.map(user.locations, fn g -> g.id end)
    }
  end
end
