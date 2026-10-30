#
# Task runners for this project's development lifecycle.
#

.PHONY: install build version help

help:
	@echo "Available targets:"
	@echo "  install  - Install the LaTeX toolchain (TinyTeX and packages), via mise"
	@echo "  build    - Build the CV to PDF, in dist/"
	@echo "  version  - Tag a release point"
	@echo "  help     - Show this help message"

install:
	sh run/install

build:
	./run/build

version:
	./run/version
