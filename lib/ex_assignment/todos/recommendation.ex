defmodule ExAssignment.Todos.Recommendation do
  @moduledoc false
  use Ecto.Schema

  alias __MODULE__
  alias ExAssignment.Todos
  alias ExAssignment.Todos.Recommendation
  alias ExAssignment.Todos.Todo

  import Ecto.Changeset

  @type t() :: %__MODULE__{
          todo: Todo.t() | Ecto.Association.NotLoaded.t() | nil,
          completed_at: DateTime.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "recommendation" do
    field :completed_at, :utc_datetime
    belongs_to :todo, Todo
    timestamps()
  end

  def create_changeset(attrs), do: create_changeset(%Recommendation{}, attrs)

  def create_changeset(%Recommendation{} = recommendation, attrs) do
    recommendation
    |> Ecto.Changeset.cast(attrs, [:todo_id, :completed_at])
    |> Ecto.Changeset.validate_required([:todo_id])
    |> check_if_recommendation_exist?()
  end

  def update_changeset(%Recommendation{} = recommendation, attrs) do
    recommendation
    |> Ecto.Changeset.cast(attrs, [:completed_at])
    |> Ecto.Changeset.validate_required([:completed_at])
  end

  # only create a new todo if there is no existing todo where the completed_at field is null
  def check_if_recommendation_exist?(%Ecto.Changeset{valid?: true} = changeset) do
    recommendation = Todos.get_todo_recommendation()

    if(recommendation) do
      add_error(changeset, :recommendation, "todo recommendation already exist")
    else
      changeset
    end
  end

  def check_if_recommendation_exist?(changeset), do: changeset
end
