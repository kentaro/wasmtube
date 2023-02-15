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

  test "call_function/3" do
    result =
      Wasmtube.from_file(@wasm_file)
      |> Wasmtube.call_function(
        "echo",
        data: %{
          args: "Hello World!"
        }
      )

    assert result == %{
             "args" => "Hello World!"
           }
  end
end
