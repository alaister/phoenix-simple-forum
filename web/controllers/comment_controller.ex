defmodule Forum.CommentController do
  use Forum.Web, :controller

  alias Forum.{Comment, Post}

  plug :authenticate_user when action in [:create, :edit, :update, :delete]

  def create(conn, %{"post_id" => id, "comment" => comment_params}) do
    post_query = from p in Post,
                 where: p.id == ^id,
                 join: c in assoc(p, :comments),
                 join: u in assoc(c, :user),
                 preload: [comments: {c, user: u}]

    post = Repo.one(post_query)
    changeset =
      post
        |> build_assoc(:comments, user_id: conn.assigns.current_user.id)
        |> Comment.changeset(comment_params)
      
      case Repo.insert(changeset) do
        {:ok, _comment} ->
          conn
            |> put_flash(:info, "Comment added successfully!")
            |> redirect(to: post_path(conn, :show, post))
          {:error, changeset} ->
            conn
              |> put_flash(:error, "Comment must have a body!")
              |> render(Forum.PostView, "show.html", comment_changeset: changeset, post: post)
      end
  end

  def edit(conn, %{"id" => id, "post_id" => post_id}) do
    comment = Repo.get(Comment, id)
    post = Repo.get(Post, post_id)
    changeset = Comment.changeset(comment)
    render conn, "edit.html", changeset: changeset, comment: comment, post: post
  end

  def update(conn, %{"comment" => comment_params, "id" => id, "post_id" => post_id}) do
    comment = Repo.get(Comment, id)
    post = Repo.get(Post, post_id)
    changeset = Comment.changeset(comment, comment_params)

    case Repo.update(changeset) do
      {:ok, _new_post} ->
        conn
          |> put_flash(:info, "Comment updated successfully!")
          |> redirect(to: post_path(conn, :show, post))

      {:error, changeset} ->
        conn
          |> put_flash(:error, "Oops something went wrong! Please check the errors below")
          |> render("edit.html", changeset: changeset, comment: comment, post: post)
    end
  end

  def delete(conn, %{"post_id" => post_id, "id" => id}) do
    post = Repo.get(Post, post_id)
    comment = Repo.get(Comment, id)
    Repo.delete!(comment)

    conn
      |> put_flash(:info, "Comment deleted successfully!")
      |> redirect(to: post_path(conn, :show, post))
  end
end