defmodule Forum.SessionController do
  use Forum.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => user, "password" => pass}}) do
    case Forum.Auth.login_by_email_and_pass(conn, user, pass, repo: Forum.Repo) do
      {:ok, conn} ->
        conn
          |> put_flash(:info, "Welcome back!")
          |> redirect(to: home_path(conn, :index))
      {:error, _reason, conn} ->
        conn
          |> put_flash(:error, "Invalid email/password combination")
          |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
      |> Forum.Auth.logout()
      |> redirect(to: home_path(conn, :index))
  end
end