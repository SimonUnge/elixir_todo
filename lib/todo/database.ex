defmodule Todo.Database do
  use GenServer
  @db_folder "./persist"

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.get(key)
  end

  def init(_) do
    File.mkdir_p(@db_folder)
    {:ok, start_workers()}
  end

  def handle_call({:choose_worker, name}, _from, state) do
    {:reply, Map.get(state, :erlang.phash2(name, 3)), state}
  end

  defp start_workers() do
    for n <- 0..2, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
      {n, pid}
    end
  end

  defp choose_worker(name) do
    GenServer.call(__MODULE__, {:choose_worker, name})
  end
end
