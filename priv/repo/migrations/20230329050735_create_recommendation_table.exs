defmodule ExAssignment.Repo.Migrations.CreateRecommendationTable do
  use Ecto.Migration

  def change do
    create table(:recommendation) do
      add :todo_id, references(:todos)
      add :completed_at, :utc_datetime
      timestamps()
    end

    create index(:recommendation, [:todo_id])
  end
end
