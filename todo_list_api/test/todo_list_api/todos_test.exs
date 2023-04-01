defmodule TodoListApi.TodosTest do
  # use TodoListApi.DataCase

  # alias TodoListApi.Todos

  # # doctest TodoListApi.Todos, import: true

  # describe "tasks" do
  #   alias TodoListApi.Todos.Task

  #   import TodoListApi.TodosFixtures

  #   @invalid_attrs %{completed: nil, description: nil, title: nil}

  #   test "list_tasks/0 returns all tasks" do
  #     task = task_fixture()
  #     assert Todos.list_tasks() == [task]
  #   end

  #   test "get_task!/1 returns the task with given id" do
  #     task = task_fixture()
  #     assert Todos.get_task!(task.id) == task
  #   end

  #   test "create_task/1 with valid data creates a task" do
  #     valid_attrs = %{completed: true, description: "some description", title: "some title"}

  #     assert {:ok, %Task{} = task} = Todos.create_task(valid_attrs)
  #     assert task.completed == true
  #     assert task.description == "some description"
  #     assert task.title == "some title"
  #   end

  #   test "create_task/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Todos.create_task(@invalid_attrs)
  #   end

  #   test "update_task/2 with valid data updates the task" do
  #     task = task_fixture()
  #     update_attrs = %{completed: false, description: "some updated description", title: "some updated title"}

  #     assert {:ok, %Task{} = updated_task} = Todos.update_task(task.id, update_attrs)
  #     assert updated_task.completed == false
  #     assert updated_task.description == "some updated description"
  #     assert updated_task.title == "some updated title"
  #   end

  #   test "update_task/2 with invalid data returns error changeset" do
  #     task = task_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Todos.update_task(task.id, @invalid_attrs)
  #     assert task == Todos.get_task!(task.id)
  #   end

  #   test "delete_task/1 deletes the task" do
  #     task = task_fixture()
  #     assert {:ok, %Task{}} = Todos.delete_task(task.id) # Pass the task ID instead of the whole struct
  #     assert_raise Ecto.NoResultsError, fn -> Todos.get_task!(task.id) end
  #   end

  #   test "change_task/1 returns a task changeset" do
  #     task = task_fixture()
  #     assert %Ecto.Changeset{} = Todos.change_task(task)
  #   end
  # end
end
