defmodule Wasmtube.FileWatcher do
  use GenServer

  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  @impl GenServer
  def init(args) do
    dirs = Keyword.get(args, :dirs, [])
    wasm_file = Keyword.get(args, :wasm_file)
    watcher_name = Keyword.get(args, :watcher_name, :"#{__MODULE__}.Watcher")
    worker = Keyword.get(args, :worker, Wasmtube.Worker)

    {:ok, watcher_pid} =
      FileSystem.start_link(
        dirs: dirs,
        name: watcher_name
      )

    FileSystem.subscribe(watcher_pid)

    {:ok,
     %{
       wasm_file: wasm_file,
       worker: worker,
       watcher_pid: watcher_pid,
     }}
  end

  @impl GenServer
  def handle_info({:file_event, _watcher_pid, {path, events}}, state) do
    if path == state.wasm_file do
      if :created in events or :modified in events do
        GenServer.cast(state.worker, {:reload, path})
      end
    end

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    # Your own logic when monitor stop
    {:noreply, state}
  end
end
