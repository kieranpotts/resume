#!/usr/bin/env sh

# The directory where the source files are located, relative to the project root.
SOURCE_DIR=src

# The directory where the generated output files will be created, relative to
# the project root
BUILD_DIR=dist

# Generate the CV PDF.
docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
  -D $BUILD_DIR \
  -o "Kieran Potts - CV.pdf" \
  $SOURCE_DIR/cv.adoc

# Generate the full version of the CV PDF.
docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
  -a full \
  -D $BUILD_DIR \
  -o "Kieran Potts - CV (Full Version).pdf" \
  $SOURCE_DIR/cv.adoc

# The above commands use a temporary container to generate the initial PDF
# files. We want to modify these files using the `cpdf` tool, but Docker-generated
# files will be owned by root and other users will have only read access. To
# allow editing, change ownership to the current user.
#
me=$(whoami)
sudo chown $me:$me "$BUILD_DIR/Kieran Potts - CV.pdf"
sudo chown $me:$me "$BUILD_DIR/Kieran Potts - CV (Full Version).pdf"

# Use cpdf to make some adjustments to the generated PDF files, eg. give them
# titles (which are not created by asciidoctor-pdf), set the zoom so the width
# of the page fits the window's viewport.
#
# This tool sends to stdout an annoying license message, which I'm redirecting away.
#
# https://github.com/coherentgraphics/cpdf-binaries/
#
./bin/cpdf "$BUILD_DIR/Kieran Potts - CV.pdf" \
  AND -set-title "Kieran Potts - CV" \
  AND -display-doc-title true \
  AND -set-page-layout SinglePage \
  AND -set-page-mode UseNone \
  AND -open-at-page-custom "[1 /FitH]" \
  -o "$BUILD_DIR/Kieran Potts - CV.pdf" &> /dev/null

./bin/cpdf "$BUILD_DIR/Kieran Potts - CV (Full Version).pdf" \
  AND -set-title "Kieran Potts - CV (Full Version)" \
  AND -display-doc-title true \
  AND -set-page-layout SinglePage \
  AND -set-page-mode UseNone \
  AND -open-at-page-custom "[1 /FitH]" \
  -o "$BUILD_DIR/Kieran Potts - CV (Full Version).pdf" &> /dev/null
