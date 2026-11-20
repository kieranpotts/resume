#
# Task runners for this project's development lifecycle.
#

.PHONY: install build build-docx version help

help:
	@echo "Available targets:"
	@echo "  install     - Install the toolchain (TinyTeX, LaTeX packages, Pandoc), via mise"
	@echo "  build       - Build the CV to PDF, in dist/"
	@echo "  build-docx  - Build the CV to Word (.docx), in dist/"
	@echo "  version     - Tag a release point"
	@echo "  help        - Show this help message"

install:
	sh run/install

build:
	./run/build

build-docx:
	sh run/build-docx

version:
	./run/version
