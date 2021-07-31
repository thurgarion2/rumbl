defmodule RumblWeb.Auth do
  import Phoenix.Controller
  import Plug.Conn

  alias Rumbl.Accounts
  alias RumblWeb.Router.Helpers, as: Routes


  def init(_) do
    nil
  end

  def call(conn, _) do
    user_id = get_session(conn, :user_id)

    cond do
      _user = conn.assigns[:current_user] ->
        conn
      user = user_id && Accounts.get_user(user_id) ->
        put_current_user(conn, user)
      true ->
        assign(conn, :current_user, nil)
    end

  end


  def login(conn, user) do
    conn
    |> put_current_user(user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  def authenticate_user(conn, _opts) do

    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end

  end


  import Argon2, only: [verify_pass: 2, no_user_verify: 0]


  def login_by_username_and_pass(conn, username, given_pass, _opts) do
    user = Accounts.get_user_by(username: username)

    cond do
      user && verify_pass(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}

      user ->
        {:error, :unauthorized, conn}

      true ->
        no_user_verify()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end
end
