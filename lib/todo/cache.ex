defmodule Todo.Cache do 
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(pid, todo_list_name) do
    GenServer.call(pid, {:server_process, todo_list_name})
  end

  def init(_) do
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
        {:ok, new_server} = Todo.Server.start()
        {:reply,
         new_server,
         Map.put(state, todo_list_name, new_server)}
    end
  end
end
