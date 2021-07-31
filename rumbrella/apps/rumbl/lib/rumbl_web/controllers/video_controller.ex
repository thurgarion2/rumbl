defmodule RumblWeb.VideoController do
  use RumblWeb, :controller

  alias Rumbl.Accounts

  def action(conn, _) do
    apply(__MODULE__,
      action_name(conn),
      [conn, conn.params, conn.assigns.current_user])
  end

  plug :load_categories when action in [:new, :create, :edit, :update]

  defp load_categories(conn, _opts) do
    categories = Accounts.list_categories()
    assign(conn, :categories, categories)
  end

  def index(conn, _params, user) do
    videos = Accounts.list_videos(user)
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, user) do
    changeset =
      user
      |> Ecto.build_assoc(:videos)
      |> Accounts.change_video()

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}, user) do
    case Accounts.create_video(user, video_params) do
      {:ok, _video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: Routes.video_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    video = Accounts.get_video!(user, id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, user) do
    video = Accounts.get_video!(user, id)
    changeset = Accounts.change_video(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, user) do
    video = Accounts.get_video!(user, id)

    case Accounts.update_video(video, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: Routes.video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    video = Accounts.get_video!(user, id)
    {:ok, _video} = Accounts.delete_video(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: Routes.video_path(conn, :index))
  end
end
