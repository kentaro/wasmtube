defmodule Wasmtube.Worker do
  use GenServer

  alias Wasmtube.FileWatcher

  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  @impl GenServer
  def init(args) do
    dirs = Keyword.get(args, :dirs, [])
    wasm_file = Keyword.get(args, :wasm_file)

    {:ok, watcher_pid} =
      FileWatcher.start_link(
        dirs: dirs,
        wasm_file: wasm_file,
        worker_pid: self()
      )

    wasm_bridge = load_wasm(wasm_file)

    {:ok,
     %{
       wasm_bridge: wasm_bridge,
       watcher_pid: watcher_pid,
       started: Time.utc_now(),
       version: 0
     }}
  end

  def call_function(worker_pid, function, arg) do
    worker_pid |> GenServer.call({:call_function, function, arg})
  end

  def version(worker_pid) do
    GenServer.call(worker_pid, :version)
  end

  @impl GenServer
  def handle_call(:started, _from, state) do
    {:reply, state.started, state}
  end

  @impl GenServer
  def handle_call(:version, _from, state) do
    {:reply, state.version, state}
  end

  @impl GenServer
  def handle_call({:call_function, function, arg}, _from, state) do
    result =
      state.wasm_bridge
      |> Wasmtube.Bridge.call_function(function, arg)

    {:reply, result, state}
  end

  @impl GenServer
  def handle_cast({:reload, path}, state) do
    wasm_bridge = load_wasm(path)

    {:noreply,
     %{
       state
       | wasm_bridge: wasm_bridge,
         started: Time.utc_now(),
         version: state.version + 1
     }}
  end

  defp load_wasm(path) do
    Wasmtube.from_file(path)
  end
end
