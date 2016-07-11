defmodule Forum.PostController do
  use Forum.Web, :controller

  import Ecto.Query

  alias Forum.{Post, Comment}

  plug :authenticate_user when action in [:new, :create, :edit, :delete]

  def index(conn, params) do
    posts =
    	Post
        |> order_by(desc: :inserted_at)
        |> preload(:user)
        |> Repo.paginate(params)
    render conn, "index.html", posts: posts
  end

  def show(conn, %{"id" => id}) do
    comment_query = from c in Comment,
                    order_by: [desc: c.inserted_at],
                    preload: :user

    post_query = from p in Post,
                 where: p.id == ^id,
                 preload: [comments: ^comment_query]

    post = Repo.one(post_query)

    comment_changeset = Comment.changeset(%Comment{})
    render(conn, "show.html", post: post, comment_changeset: comment_changeset)
  end

  def new(conn, _params) do
    changeset = Post.changeset(%Post{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"post" => post_params}) do
    changeset =
      conn.assigns.current_user
        |> build_assoc(:posts)
        |> Post.changeset(post_params)

    case Repo.insert(changeset) do
      {:ok, post} ->
        conn
          |> put_flash(:info, "Post created successfully!")
          |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Oops something wen't wrong! Please check the errors below")
          |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    post = Repo.get(Post, id)
    changeset = Post.changeset(post)
    render conn, "edit.html", changeset: changeset, post: post
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Repo.get(Post, id)
    changeset = Post.changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        conn
          |> put_flash(:info, "Post updated successfully!")
          |> redirect(to: post_path(conn, :show, post))

      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get(Post, id)
    if(post.user_id == conn.assigns.current_user.id) do
      Repo.delete!(post)

      conn
        |> put_flash(:info, "Post deleted successfully!")
        |> redirect(to: post_path(conn, :index))
    else
      conn
        |> put_flash(:error, "Unauthorized!")
        |> redirect(to: post_path(conn, :show, post))
    end
    
  end
end
