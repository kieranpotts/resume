# Requirements

The only requirements are:

* Make
* [mise](https://mise.jdx.dev)
* A LaTeX editor

The LaTeX toolchain is [TinyTeX](https://yihui.org/tinytex/), pinned in
`mise.toml`, plus the packages listed in `run/install`. Install it with:

```sh
make install
```

This installs TinyTeX under mise's data directory, not system-wide, so it
needs no `sudo`. It is the same toolchain on the host, in the devcontainer,
and in CI.

On Windows, it is RECOMMENDED to run the build commands from WSL 2. Linux
emulators like Git Bash are NOT sufficient.

Finally, make sure that each of the `run/*` scripts are executable:

```sh
chmod +x run/*
```
