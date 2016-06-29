defmodule Forum.Repo.Migrations.ReferenceUsersInPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
    end
    create index(:posts, [:user_id])
  end
end
