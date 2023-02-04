# Wasmtube

Wasmtube is a bridging library that allows you to communicate between Elixir and Wasm via JSON-encoded structured values.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `wasmtube` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wasmtube, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
Wasmtube.from_file("hello_world.wasm")
|> Wasmtube.call_function("hello", %{arg: "World"})
```

`Wasmtube.call_function` takes 2 arguments:

- Function name that is same as one in Wasm code.
- Arguments that are represented by `Map` in Elixir

When you call a function defined in Wasm from Elixir, arguments passed into the function and values returned from it are conveyed via `WebAssembly.Memory`.

## Author

Kentaro Kuribayashi
