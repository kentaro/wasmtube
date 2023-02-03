defmodule WasmtubeTest do
  use ExUnit.Case
  doctest Wasmtube

  test "greets the world" do
    assert Wasmtube.hello() == :world
  end
end
