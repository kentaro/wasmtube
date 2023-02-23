defmodule Wasmtube.Worker.Test do
  use ExUnit.Case, async: true
  doctest Wasmtube.Worker

  @watch_dir "test/wasm_test/target/wasm32-unknown-unknown/release"
  @wasm_file "test/wasm_test/target/wasm32-unknown-unknown/release/wasm_test.wasm"

  def start_worker(name) do
    {:ok, worker_pid} =
      Wasmtube.Worker.start_link(
        dirs: [@watch_dir],
        wasm_file: @wasm_file,
        name: name
      )

    worker_pid
  end

  test "start_link/1" do
    worker_pid = start_worker(Wasmtube.Worker.Test.StartLink)
    assert is_pid(worker_pid)
  end

  test "call_function" do
    worker_pid = start_worker(Wasmtube.Worker.Test.CallFunction)

    result =
      worker_pid
      |> GenServer.call({
        :call_function,
        :echo,
        data: %{
          args: "Hello World!"
        }
      })

    assert result == %{
             "args" => "Hello World!"
           }
  end
end
