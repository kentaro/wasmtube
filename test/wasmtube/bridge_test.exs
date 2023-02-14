defmodule Wasmtube.Bridge.Test do
  use ExUnit.Case, async: true
  doctest Wasmtube

  @wasm_file "test/wasm_test/target/wasm32-unknown-unknown/release/wasm_test.wasm"
  # This image is taken from:
  # https://commons.wikimedia.org/wiki/File:So_happy_smiling_cat.jpg
  @image_file "test/assets/cat.jpg"

  test "new/1 with binary" do
    bridge = Wasmtube.Bridge.new(binary: File.read!(@wasm_file))
    assert %Wasmtube.Bridge{} = bridge
  end

  test "new/1 with file" do
    bridge = Wasmtube.Bridge.new(file: @wasm_file)
    assert %Wasmtube.Bridge{} = bridge
  end

  test "call_function/3 with struct" do
    bridge = Wasmtube.Bridge.new(file: @wasm_file)

    result =
      bridge
      |> Wasmtube.Bridge.call_function(
        "echo",
        struct: %{
          args: "Hello World!"
        }
      )

    assert result == %{
             "args" => "Hello World!"
           }
  end

  test "call_function/3 with binary" do
    bridge = Wasmtube.Bridge.new(file: @wasm_file)

    result =
      bridge
      |> Wasmtube.Bridge.call_function(
        "image_size",
        binary: File.read!(@image_file)
      )

    assert result == %{
             "width" => 429,
             "height" => 500
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
        12
      )

    assert result == "Hello World!"
  end

  test "read_binary/2" do
    bridge = Wasmtube.Bridge.new(file: @wasm_file)

    bridge
    |> Wasmtube.Bridge.write_binary("Hello World!")

    result =
      bridge
      |> Wasmtube.Bridge.read_binary(12)

    assert result == "Hello World!"
  end
end
