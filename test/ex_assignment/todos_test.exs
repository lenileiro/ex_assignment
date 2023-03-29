defmodule ExAssignment.TodosTest do
  use ExAssignment.DataCase

  alias ExAssignment.Todos.Recommendation
  alias ExAssignment.Todos

  describe "todos" do
    alias ExAssignment.Todos.Todo

    import ExAssignment.TodosFixtures

    @invalid_attrs %{done: nil, priority: nil, title: nil}

    test "create_todo_recommendation/1 with valid data creates a todo recommendation" do
      todo = todo_fixture()

      assert {:ok, %Recommendation{} = recommendation} =
               Todos.create_todo_recommendation(%{todo_id: todo.id})

      assert recommendation.todo_id == todo.id
      refute recommendation.completed_at
    end

    test "create_todo_recommendation/1 returns error changeset when existing a todo recommendation that is not completed" do
      todo = todo_fixture()
      todo_recommendation_fixture(%{todo_id: todo.id})
      assert {:error, %Ecto.Changeset{}} = Todos.create_todo_recommendation(%{todo_id: todo.id})
    end

    test "create_todo_recommendation/1 creates a todo recommendation when existing a todo recommendation that is completed" do
      todo = todo_fixture()
      todo_recommendation_fixture(%{todo_id: todo.id, completed_at: DateTime.utc_now()})

      assert {:ok, %Recommendation{} = recommendation} =
               Todos.create_todo_recommendation(%{todo_id: todo.id})

      assert recommendation.todo_id == todo.id
      refute recommendation.completed_at
    end

    test "update_todo_recommendation/2 with valid data updates the todo" do
      todo = todo_fixture()
      recommendation = todo_recommendation_fixture(%{todo_id: todo.id})

      assert {:ok, %Recommendation{} = recommendation} =
               Todos.update_todo_recommendation(recommendation, %{
                 completed_at: DateTime.utc_now()
               })

      assert recommendation.todo_id == todo.id
      assert recommendation.completed_at
    end

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert Todos.list_todos() == [todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert Todos.get_todo!(todo.id) == todo
    end

    test "create_todo/1 with valid data creates a todo" do
      valid_attrs = %{done: true, priority: 42, title: "some title"}

      assert {:ok, %Todo{} = todo} = Todos.create_todo(valid_attrs)
      assert todo.done == true
      assert todo.priority == 42
      assert todo.title == "some title"
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      update_attrs = %{done: false, priority: 43, title: "some updated title"}

      assert {:ok, %Todo{} = todo} = Todos.update_todo(todo, update_attrs)
      assert todo.done == false
      assert todo.priority == 43
      assert todo.title == "some updated title"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = Todos.update_todo(todo, @invalid_attrs)
      assert todo == Todos.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = Todos.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = Todos.change_todo(todo)
    end
  end
end
