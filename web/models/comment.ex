defmodule Forum.Comment do
  use Forum.Web, :model

  schema "comments" do
    field :comment, :string
    belongs_to :user, Forum.User
    belongs_to :post, Forum.Post

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:comment])
    |> validate_required([:comment])
  end
end
