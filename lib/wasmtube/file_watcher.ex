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
    worker_pid = Keyword.get(args, :worker_pid)

    extra_arg =
      case :os.type do
        {:unix, :darwin} -> [
          latency: 0,
          no_defer: true
        ]
        _ -> []
      end

    {:ok, watcher_pid} =
      FileSystem.start_link(
        Keyword.merge([
        dirs: dirs,
        name: watcher_name,
      ], extra_arg)
    )

    FileSystem.subscribe(watcher_pid)

    {:ok,
     %{
       wasm_file: wasm_file,
       worker_pid: worker_pid,
       watcher_pid: watcher_pid
     }}
  end

  @impl GenServer
  def handle_info({:file_event, _watcher_pid, {path, events}}, state) do
    if path == state.wasm_file do
      if :created in events or :modified in events or :inodemetamod in events do
        GenServer.cast(state.worker_pid, {:reload, path})
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
