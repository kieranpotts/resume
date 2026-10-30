# Development

To install the LaTeX toolchain, run:

```sh
make install
```

Run it once on a new machine or devcontainer, and again whenever `mise.toml`
or the package list in `run/install` changes.

To build the résumé to PDF format from the source Tex file, run:

```sh
make build
```

The output file is `./dist/kieran-potts-cv.pdf`. Other artifacts are also
outputted by the compiler to the `dist` directory.

The build stops at the first LaTeX error, rather than prompting for input.
See `dist/kieran-potts-cv.log` for the details.

## Upgrading TeX Live

TinyTeX is pinned to the last build of TeX Live 2022, and its packages come
from the frozen TeX Live 2022 archive, so the PDF does not change unless the
source does. Later TeX Live releases change the layout: TeX Live 2024 pushes
the CV onto three pages, and TeX Live 2025 replaces Source Serif Pro with
Source Serif 4. To upgrade, change the version in `mise.toml` and the archive
URL in `run/install` together, then compare the PDF before and after.
