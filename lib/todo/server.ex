defmodule Todo.Server do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
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
  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_call({:add_entry, entry}, _from, {name, list}) do
    new_list = Todo.List.add_entry(list, entry)
    Todo.Database.store(name, new_list)
    {:reply, :ok, {name, new_list}}
  end

  def handle_call({:entries, date}, _from, {_name, list} = state) do
    entries = Todo.List.entries(list, date)
    {:reply, entries, state}
  end

  def handle_call({:delete_entry, id}, _from, {name, list}) do
    {:reply, :ok, {name, Todo.List.delete_entry(list, id)}}
  end
end
