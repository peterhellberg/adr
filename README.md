# adr

A tool for managing ADRs _(Architecture Decision Records)_ in a directory _(ideally inside of a repo)_.

> [!Note]
> Initially based on <https://github.com/bradcypert/adl/>,
> then adjusted to be built as a `.wasm` as well as depending on
> <https://github.com/karlseguin/zul/> for `DateTime` formatting
> instead of <https://github.com/frmdstryr/zig-datetime>.

## Background

I wondered how much smaller a `.wasm` version of this CLI would be in comparison to a native executable.
As it turns out… pretty small (`33K`)

## Requirements

 - [Git](https://git-scm.com/)
 - [Wasmtime](https://wasmtime.dev/)
 - [Zig](https://ziglang.org/download/#release-master) (recent master)

## Installation

1. Clone the `adr` repo somewhere
2. *OPTIONALLY:* Rebuild the `adr.wasm` using `zig build`
3. Add an `adr` alias to your shell, something like:
```shell
alias adr='wasmtime run ~/Code/GitHub/peterhellberg/adr/zig-out/bin/adr.wasm --dir . --'
```

> [!Tip]
> You can also run the CLI via `zig build run -- create Your new adr`

## Usage

### Generating a new ADR

```
adr create WebAssembly runtime for adr
```

This will create _(or update)_ a `README.md` in your `adr/` directory _(creating that directory if necessary)_.

For example, if this was your first ADR, it would create the file `<YOUR_PROJECT_ROOT>/adr/00000-WebAssembly-runtime-for-adr.md`.

It would then update the README in the same directory with a link to the newly created ADR document.

### Regenerating the README

```sh
adr regen
```

✨
