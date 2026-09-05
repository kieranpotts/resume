#
# Task runners for this project's development lifecycle.
#

.PHONY: start build stop version help

help:
	@echo "Available targets:"
	@echo "  start    - Start the LaTeX Docker container"
	@echo "  build    - Build the CV to PDF, in dist/"
	@echo "  stop     - Stop the LaTeX Docker container"
	@echo "  version  - Tag a release point"
	@echo "  help     - Show this help message"

start:
	./run/start

build:
	./run/build

stop:
	./run/stop

version:
	./run/version
