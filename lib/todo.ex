defmodule Todo do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(
      todo_list.entries,
      todo_list.auto_id,
      entry
    )
    %Todo{todo_list |
          auto_id: todo_list.auto_id + 1,
          entries: new_entries
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list
      {:ok, old_entry} ->
        old_id = old_entry.id
        new_entry = %{id: ^old_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, entry_id, new_entry)
        %Todo{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %Todo{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end

defmodule Todo.CsvImporter do
  def import(file) do
    file
    |> read_lines
    |> create_entries
    |> Todo.new
  end

  defp read_lines(file) do
    File.stream!(file)
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  defp create_entries(lines) do
    lines
    |> Stream.map(&extract_fields/1)
    |> Stream.map(&create_entry/1)
  end

  defp extract_fields(line) do
    [date, title] = String.split(line, ",")
    {create_date(date), title}
  end

  defp create_date(date) do
    [y,m,d] =
      date
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)
    {:ok, date} = Date.new(y,m,d);
    date
  end

  defp create_entry({date, title}) do
    %{date: date, title: title}
  end
end

defimpl String.Chars, for: Todo do
  def to_string(_) do
    "#TodoFubah"
  end
end

defimpl Collectable, for: Todo do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    Todo.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done) do
    todo_list
  end

  defp into_callback(todo_list, :halt) do
    :ok
  end
end