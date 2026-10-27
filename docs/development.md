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

The output file is `./dist/kieran-potts-cv.pdf`. Other artifacts are also
outputted by the compiler to the `dist` directory.

To stop the Docker container, run:

```sh
make stop
```
