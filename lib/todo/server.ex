defmodule Todo.Server do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def add_entry(pid, entry) do
     GenServer.call(pid, {:add_entry, entry})
  end

  def entries(pid, date) do
     GenServer.call(pid, {:entries, date})
  end

  def delete_entry(pid, entry_id) do
     GenServer.call(pid, {:delete_entry, entry_id})
  end

  @impl GenServer
  def init(_) do
    {:ok, Todo.List.new()}
  end

  @impl GenServer
  def handle_call({:add_entry, entry}, _from, state) do
    new_state = Todo.List.add_entry(state, entry)
    {:reply, :ok, new_state}
  end

  def handle_call({:entries, date}, _from, state) do
    entries = Todo.List.entries(state, date)
    {:reply, entries, state}
  end

  def handle_call({:delete_entry, id}, _from, state) do
    {:reply, :ok, Todo.List.delete_entry(state, id)}
  end
end
