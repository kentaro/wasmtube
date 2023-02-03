defmodule Wasmtube.Bridge do
  defstruct [:instance, :store, :memory, :index, :buffer_size]

  @default_index 42
  @default_buffer_size 1024

  def new([binary: wasm_binary]) when is_binary(wasm_binary) do
    {:ok, instance} =
      %{
        bytes: wasm_binary
      }
      |> Wasmex.start_link()

    {:ok, store} = instance |> Wasmex.store()
    {:ok, memory} = instance |> Wasmex.memory()

    %Wasmtube.Bridge{
      instance: instance,
      store: store,
      memory: memory,
      index: @default_index,
      buffer_size: @default_buffer_size
    }
  end

  def new([file: wasm_file]) do
    wasm_binary = File.read!(wasm_file)
    new(binary: wasm_binary)
  end

  def call_function(bridge, function, args) when is_map(args) do
    args = args |> Map.put(:buffer_size, bridge.buffer_size)
    json = Jason.encode!(args)
    bridge |> write_binary(json)

    {:ok, [pointer]} = Wasmex.call_function(
      bridge.instance,
      function,
      [bridge.index, json |> String.length()]
    )

    bridge
    |> read_binary(pointer)
    # TODO: This is a hack to remove the null byte at the end of the string
    |> String.split(<<0>>)
    |> List.first()
    |> Jason.decode!()
  end

  def write_binary(bridge, binary) do
    Wasmex.Memory.write_binary(
      bridge.store,
      bridge.memory,
      bridge.index,
      binary
    )
  end

  def read_binary(bridge, pointer) do
    Wasmex.Memory.read_string(
      bridge.store,
      bridge.memory,
      pointer,
      bridge.buffer_size
    )
  end
end
