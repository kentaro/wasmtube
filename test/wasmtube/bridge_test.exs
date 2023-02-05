defmodule Wasmtube.Bridge.Test do
  use ExUnit.Case, async: true
  doctest Wasmtube

  @wasm_file "test/wasm_test/target/wasm32-unknown-unknown/release/wasm_test.wasm"

  test "new/1 with binary" do
    bridge = Wasmtube.Bridge.new(binary: File.read!(@wasm_file))
    assert %Wasmtube.Bridge{} = bridge
  end

  test "new/1 with file" do
    bridge = Wasmtube.Bridge.new(file: @wasm_file)
    assert %Wasmtube.Bridge{} = bridge
  end

  test "call_function/3" do
    bridge = Wasmtube.Bridge.new(file: @wasm_file)

    result =
      bridge
      |> Wasmtube.Bridge.call_function(
        "echo",
        %{
          arg: "Hello World!"
        }
      )

    assert result == %{
             "arg" => "Hello World!",
             "buffer_size" => 1024
           }
  end

  test "write_binary/2" do
    bridge = Wasmtube.Bridge.new(file: @wasm_file)

    bridge
    |> Wasmtube.Bridge.write_binary("Hello World!")

    result =
      Wasmex.Memory.read_string(
        bridge.store,
        bridge.memory,
        bridge.index,
        bridge.buffer_size
      )
      |> String.split(<<0>>)
      |> List.first()

    assert result == "Hello World!"
  end

  test "read_binary/2" do
    bridge = Wasmtube.Bridge.new(file: @wasm_file)

    bridge
    |> Wasmtube.Bridge.write_binary("Hello World!")

    result =
      bridge
      |> Wasmtube.Bridge.read_binary(bridge.index)
      |> String.split(<<0>>)
      |> List.first()

      assert result == "Hello World!"
  end
end
