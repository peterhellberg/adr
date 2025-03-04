# 00000 - WebAssembly runtime for adr

## Abstract

I decided to compile the `adr` CLI as a `.wasm`, which means I need a WebAssembly runtime.

## Context and Problem Statement

In order to run the `adr.wasm` a WebAssembly runtime is needed.

The runtime has to support writing to the current directory, and retrieval of the current time.

## Considered Options

- Wasmtime
- Wasmer

## Decision Outcome

Wasmtime was picked since it has a very convenient `--dir` flag.

<!-- Add additional information here, comparison of options, research, etc -->
