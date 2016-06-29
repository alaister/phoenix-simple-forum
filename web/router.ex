defmodule Forum.Router do
  use Forum.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Forum.Auth, repo: Forum.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Forum do
    pipe_through [:browser] # Use the default browser stack

    get "/", PostController, :index, as: :home
    resources "/posts", PostController do
      resources "/comments", CommentController, only: [:create, :delete, :edit, :update]
    end
    get "/login", SessionController, :new, as: :login
    post "/login", SessionController, :create, as: :login
    delete "/logout", SessionController, :delete, as: :logout
    get "/register", UserController, :new, as: :register
    post "/register", UserController, :create, as: :register
  end

  # Other scopes may use custom stacks.
  # scope "/api", Forum do
  #   pipe_through :api
  # end
end
