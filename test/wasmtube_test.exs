defmodule Wasmtube.Test do
  use ExUnit.Case, async: true
  doctest Wasmtube

  @wasm_file "test/wasm_test/target/wasm32-unknown-unknown/release/wasm_test.wasm"

  test "from_binary/2" do
    bridge = Wasmtube.from_binary(File.read!(@wasm_file))
    assert %Wasmtube.Bridge{} = bridge
  end

  test "from_fire/2" do
    bridge = Wasmtube.from_file(@wasm_file)
    assert %Wasmtube.Bridge{} = bridge
  end

  test "index/2" do
    index = 256

    bridge =
      Wasmtube.from_file(@wasm_file)
      |> Wasmtube.index(index)

    assert bridge.index == index
  end

  test "buffer_size/2" do
    buffer_size = 2048

    bridge =
      Wasmtube.from_file(@wasm_file)
      |> Wasmtube.buffer_size(buffer_size)

    assert bridge.buffer_size == buffer_size
  end

  test "call_function/3" do
    result =
      Wasmtube.from_file(@wasm_file)
      |> Wasmtube.call_function(
        "echo",
        %{
          arg: "Hello World!"
        }
      )

    assert result == %{
      "arg" => "Hello World!",
      "buffer_size" => 1024,
    }
  end
end
