# Releasing

1. Update the `[Unreleased]` section of the changelog with the new release details.
2. Commit those changes as a `chore`.
3. Run `make version`. 
4. Follow the prompts to choose a version number and create a tagged release point.
5. Run `git push --follow-tags` to push the new release commit and tag.

Keep an eye on the [release workflow](https://github.com/kieranpotts/resume/actions/workflows/release.yaml).
It will automatically create a release at the tag point. The pipeline will
compile the résumé to the PDF format and attach the file to the release.

The latest release can be fetched using these URLs: \
Short form: <https://github.com/kieranpotts/resume/releases/latest/download/kieran-potts-cv.pdf> \
Long form: <https://github.com/kieranpotts/resume/releases/latest/download/kieran-potts-cv-long-form.pdf>

## Version number in the footer

The CV footer prints the release version before the date, eg. "v2.9.0 · October 2026 ·
kieranpotts.com/cv". The version is the Git tag, injected into the document at
compile time:

- `src/kieran-potts-cv.tex` defines an empty `\cvVersion` macro, and prints it
  in the footer only when it's non-empty.
- `run/build` (local builds) sets `\cvVersion` to the most recent tag, using
  `git describe --tags --abbrev=0`. Note this is the last tag, not the current
  commit, so untagged changes still show the previous version.
- The release workflow sets `\cvVersion` to the pushed tag.
- Both pass it to `pdflatex` as `\def\cvVersion{...}\input{src/kieran-potts-cv.tex}`,
  along with `-jobname=kieran-potts-cv` so the output is still named
  `kieran-potts-cv.pdf`.

Compiling the `.tex` file directly with `pdflatex` works too, but the footer
then omits the version.
