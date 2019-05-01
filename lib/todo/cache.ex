defmodule Todo.Cache do
  use GenServer

  def start_link(_) do
    IO.puts("Starting to-do cache.")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end

  def init(_) do
    Todo.Database.start_link(nil)
    {:ok, %{}}
  end

  def handle_call(
    {:server_process, todo_list_name},
    _from,
    state) do
    case Map.fetch(state, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, state}
      :error ->
        {:ok, new_server} = Todo.Server.start_link(todo_list_name)
        {:reply,
         new_server,
         Map.put(state, todo_list_name, new_server)}
    end
  end
end
