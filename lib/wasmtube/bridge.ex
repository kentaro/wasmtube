defmodule Wasmtube.Bridge do
  defstruct [:instance, :store, :memory, :index, :lock, :lock_name]

  @default_index 42
  @default_lock_name :wasmtube_lock

  def new(binary: wasm_binary) when is_binary(wasm_binary) do
    new(binary: wasm_binary, lock_name: @default_lock_name)
  end

  def new(binary: wasm_binary, lock_name: lock_name) when is_binary(wasm_binary) do
    {:ok, instance} =
      %{
        bytes: wasm_binary
      }
      |> Wasmex.start_link()

    {:ok, store} = instance |> Wasmex.store()
    {:ok, memory} = instance |> Wasmex.memory()

    lock_name = :"#{lock_name}"
    {:ok, lock} = :sleeplocks.new(1, name: lock_name)

    %Wasmtube.Bridge{
      instance: instance,
      store: store,
      memory: memory,
      index: @default_index,
      lock: lock,
      lock_name: lock_name
    }
  end

  def new(file: wasm_file) do
    new(file: wasm_file, lock_name: @default_lock_name)
  end

  def new(file: wasm_file, lock_name: lock_name) do
    wasm_binary = File.read!(wasm_file)
    new(binary: wasm_binary, lock_name: lock_name)
  end

  def call_function(bridge, function, image: image, width: width, height: height)
      when is_binary(image) do
    bridge |> call_function(function, image, [width, height])
  end

  def call_function(bridge, function, data: data) do
    json = data |> Jason.encode!()
    bridge |> call_function(function, json, [])
  end

  def call_function(bridge, function, data, args) do
    :sleeplocks.execute(bridge.lock, fn ->
      bridge |> write_binary(data)

      func_arg =
        [
          bridge.index,
          data |> byte_size(),
          args
        ]
        |> List.flatten()

      {:ok, [data_size]} =
        Wasmex.call_function(
          bridge.instance,
          function,
          func_arg
        )

      bridge
      |> read_binary(data_size)
      |> Jason.decode!()
    end)
  end

  def write_binary(bridge, binary) do
    Wasmex.Memory.write_binary(
      bridge.store,
      bridge.memory,
      bridge.index,
      binary
    )
  end

  def read_binary(bridge, data_size) do
    Wasmex.Memory.read_binary(
      bridge.store,
      bridge.memory,
      bridge.index,
      data_size
    )
  end
end
