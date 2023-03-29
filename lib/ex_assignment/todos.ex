defmodule ExAssignment.Todos do
  @moduledoc """
  Provides operations for working with todos.
  """

  import Ecto.Query, warn: false
  alias ExAssignment.Todos.Recommendation
  alias ExAssignment.Repo

  alias ExAssignment.Todos.Todo

  @doc """
  Creates a todo recommendation.
  ## Examples

      iex> create_todo_recommendation(%{field: value})
      {:ok, %Recommendation{}}

      iex> create_todo_recommendation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """

  def create_todo_recommendation(attrs \\ %{}) do
    changeset = Recommendation.create_changeset(attrs)
    Repo.insert(changeset)
  end

  @doc """
  Updates a todo recommendation.

  ## Examples

      iex> update_todo_recommendation(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo_recommendation(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo_recommendation(%Recommendation{} = recommendation, attrs) do
    recommendation
    |> Recommendation.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets todo recommendation.

  return `nil` if the Todo does not exist.

  ## Examples

      iex> get_todo_recommendation()
      %Recommendation{}

      iex> get_todo_recommendation()
      nil

  """

  def get_todo_recommendation do
    Repo.one(from(r in Recommendation, where: is_nil(r.completed_at), preload: [:todo]))
  end

  @doc """
  Returns the list of todos, optionally filtered by the given type.

  ## Examples

      iex> list_todos(:open)
      [%Todo{}, ...]

      iex> list_todos(:done)
      [%Todo{}, ...]

      iex> list_todos()
      [%Todo{}, ...]

  """
  def list_todos(type \\ nil) do
    cond do
      type == :open ->
        from(t in Todo, where: not t.done, order_by: t.priority)
        |> Repo.all()

      type == :done ->
        from(t in Todo, where: t.done, order_by: t.priority)
        |> Repo.all()

      true ->
        from(t in Todo, order_by: t.priority)
        |> Repo.all()
    end
  end

  @doc """
  Returns the next todo that is recommended to be done by the system.

  ASSIGNMENT: ...
  """
  def get_recommended() do
    todos = list_todos(:open)
    current_recommendation = get_todo_recommendation()

    unless current_recommendation || Enum.empty?(todos) do
      max_priority = Enum.min_by(todos, & &1.priority).priority

      priority_ratios = todos |> Enum.map(fn todo -> todo.priority / max_priority end)

      new_todos = Enum.zip(todos, Enum.reverse(priority_ratios))

      distribution =
        Enum.flat_map(new_todos, fn {todo, priority_ratio} ->
          Enum.reduce(1..ceil(priority_ratio), [], fn _, acc ->
            [todo | acc]
          end)
        end)

      random_number =
        if(length(distribution) == 1, do: 0, else: :rand.uniform(length(distribution) - 1))

      todo = Enum.at(distribution, random_number)
      {:ok, _} = create_todo_recommendation(%{todo_id: todo.id})
      todo
    else
      if(current_recommendation, do: current_recommendation.todo)
    end
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(id), do: Repo.get!(Todo, id)

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end

  @doc """
  Marks the todo referenced by the given id as checked (done).

  ## Examples

      iex> check(1)
      :ok

  """
  def check(id) do
    recommendation =
      Repo.one(from(r in Recommendation, where: r.todo_id == ^id, where: is_nil(r.completed_at)))

    if(recommendation) do
      {:ok, _} = update_todo_recommendation(recommendation, %{completed_at: DateTime.utc_now()})
    end

    {_, _} =
      from(t in Todo, where: t.id == ^id, update: [set: [done: true]])
      |> Repo.update_all([])

    :ok
  end

  @doc """
  Marks the todo referenced by the given id as unchecked (not done).

  ## Examples

      iex> uncheck(1)
      :ok

  """
  def uncheck(id) do
    {_, _} =
      from(t in Todo, where: t.id == ^id, update: [set: [done: false]])
      |> Repo.update_all([])

    :ok
  end
end
