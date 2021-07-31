defmodule RumblWeb.SessionController do
  use RumblWeb, :controller

  alias Rumbl.Repo

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    case RumblWeb.Auth.login_by_username_and_pass(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> RumblWeb.Auth.logout()
    |> put_flash(:info, "Logged out")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
