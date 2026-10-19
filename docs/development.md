# Development

To start the Docker container, run:

```sh
make start
```

The start script keeps the container running indefinitely (until it is
explicitly stopped), so you can re-run the build command again and again, and
each time it will be executed immediately without restarting the container.

To build the résumé to PDF format from the source Tex file, run:

```sh
make build
```

The output files are `./dist/kieran-potts-cv.pdf` (short form) and
`./dist/kieran-potts-cv-long-form.pdf` (long form). Other artifacts are also
outputted by the compiler to the `dist` directory.

Both variants are compiled from the same source. Content that only appears in
the long form is wrapped in `\ifcvlong ... \fi` (for blocks) or
`\longonly{...}` (for single items). The build selects the long form by
defining `\cvLong` before the source is input.

To stop the Docker container, run:

```sh
make stop
```
