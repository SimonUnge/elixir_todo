defmodule TodoTest do
  use ExUnit.Case
  doctest Todo

  test "create empty todo" do
    assert Todo.new() == %Todo{auto_id: 1, entries: %{}}
  end

  test "add first entry" do
    todo_list = Todo.new()
    entry = %{date: ~D[2019-04-10], title: "foobar"}
    entry_with_id = Map.put(entry, :id, todo_list.auto_id)
    updated_todo = %Todo{auto_id: 2, entries: %{1 => entry_with_id}}
    assert Todo.add_entry(todo_list, entry) == updated_todo
  end

  test "add non map entry" do
    todo_list = Todo.new()
    entry = []
    assert_raise BadMapError, fn ->
      Todo.add_entry(todo_list, entry) end
  end
  
end
