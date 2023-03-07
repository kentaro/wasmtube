# Wasmtube

Wasmtube is a bridging library that allows you to communicate between Elixir and Wasm. It supports images and structured values as arguments to be passed into Wasm functions.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed by adding `wasmtube` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wasmtube, "~> 0.1.0"}
  ]
end
```

## Usage

### Use `Wasmtube` directly

`Wasmtube` provides simple APIs to instantiate Wasm runtime with a Wasm binary and call functions to it.

```elixir
Wasmtube.from_file("hello_world.wasm")
|> Wasmtube.call_function(:hello, data: %{
  arg: "World"
})
```

### Use `Wasmtube.Worker` to be supervised

`Wasmtube.Worker` is useful when you want to put the Wasm runtime under supervision tree.

```elixir
{:ok, worker_pid} =
  Wasmtube.Worker.start_link(
    wasm_file: "hello_world.wasm",
    name: name
  )

worker_pid
  |> Wasmtube.Worker.call_function(:echo, data: %{
    arg: "World"
  })
```

## Author

Kentaro Kuribayashi <kentarok@gmail.com>
