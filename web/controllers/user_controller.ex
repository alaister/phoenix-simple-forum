defmodule Forum.UserController do
  use Forum.Web, :controller
  alias Forum.User

  plug :authenticate_user when action in [:index, :show]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
          |> Forum.Auth.login(user)
          |> put_flash(:info, "Welcome #{user.name}!")
          |> redirect(to: home_path(conn, :index))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Oops something wen't wrong! Please check the errors below")
          |> render("new.html", changeset: changeset)
    end
  end
end