defmodule Wasmtube do
  @moduledoc """
  Documentation for `Wasmtube`.
  """

  def from_binary(wasm_binary) do
    Wasmtube.Bridge.new(binary: wasm_binary)
  end

  def from_file(wasm_file) do
    Wasmtube.Bridge.new(file: wasm_file)
  end

  def index(bridge, index) do
    %Wasmtube.Bridge{
      bridge | index: index
    }
  end

  def buffer_size(bridge, buffer_size) do
    %Wasmtube.Bridge{
      bridge | buffer_size: buffer_size
    }
  end

  def call_function(bridge, function, arg) do
    bridge
    |> Wasmtube.Bridge.call_function(function, arg)
  end
end
