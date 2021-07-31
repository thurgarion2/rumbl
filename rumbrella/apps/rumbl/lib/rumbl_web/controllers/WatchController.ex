defmodule RumblWeb.WatchController do
  use RumblWeb, :controller

  alias Rumbl.Accounts

  def show(conn, %{"id" => id}) do
    video = Accounts.get_video!(id)
    render(conn, "show.html", video: video)
  end

end
