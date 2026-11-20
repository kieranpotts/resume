# Development

To install the toolchain (TinyTeX, the LaTeX packages, and Pandoc), run:

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

## Word version

To build the résumé to Word format, from the same source file, run:

```sh
make build-docx
```

The output file is `./dist/kieran-potts-cv.docx`. It is built by
[Pandoc](https://pandoc.org), which is pinned in `mise.toml`. There are three
steps in the build.

1. **`src/docx/macros.tex`** is inserted into the source, straight after
   `\begin{document}`. It replaces the CV's custom commands with simpler
   versions that Pandoc's LaTeX reader can parse. Without it, Pandoc drops
   most of the text, because it does not understand microtype's `\textls`.

2. **`src/docx/filter.lua`**, a Pandoc Lua filter, maps the document's
   structure onto custom Word styles: the title block, the three skills columns
   (as a borderless table), the engagement headings, the bullet lists, and the
   two tables.

3. **`src/docx/reference.docx`** defines those styles, plus the A4 page and
   its margins. Pandoc copies them into the output.

The Word version follows the PDF's design closely, and fits on two pages, but
it is not identical. It is set in Cambria rather than Source Serif Pro, since
recipients are unlikely to have Source Serif installed, and Word has no
equivalent of some of the LaTeX typesetting.

### Changing the styles

To change the look of the Word version, edit the styles in
`src/docx/reference.docx` in Word itself (Home → Styles → Modify). The custom
styles it defines are as follows.

- **Paragraph styles.** Title (the name), Subtitle (the specialisms row),
  Intro, Heading 1 (sections), Heading 2 (engagements), Skills Label,
  CV Bullet, CV Bullet Last, History Cell, CV Footer.

- **Character styles.** Heading Detail (the role and dates in engagement
  headings), Quiet (the grey `·` separators), Hyperlink.

- **Table styles.** ContactTable, SkillsTable, HistoryTable.

## Upgrading TeX Live

TinyTeX is pinned to the last build of TeX Live 2022, and its packages come
from the frozen TeX Live 2022 archive, so the PDF does not change unless the
source does. Later TeX Live releases change the layout: TeX Live 2024 pushes
the CV onto three pages, and TeX Live 2025 replaces Source Serif Pro with
Source Serif 4. To upgrade, change the version in `mise.toml` and the archive
URL in `run/install` together, then compare the PDF before and after.
