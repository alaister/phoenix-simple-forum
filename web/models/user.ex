defmodule Forum.User do
  use Forum.Web, :model

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :name, :string
    has_many :posts, Forum.Post
    has_many :comments, Forum.Comment

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:name, :email])
      |> validate_required([:name, :email])
      |> validate_length(:email, min: 1, max: 20)
      |> validate_format(:email, ~r/@/)
      |> unique_constraint(:email)
  end

  def registration_changeset(model, params \\ %{}) do
    model
      |> changeset(params)
      |> cast(params, [:password])
      |> validate_required([:password])
      |> validate_length(:password, min: 8, max: 100)
      |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
