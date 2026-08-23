# Releasing

1. Update the `[Unreleased]` section of the changelog with the new release details.
2. Commit those changes as a `chore`.
3. Run `make version`. 
4. Follow the prompts to choose a version number and create a tagged release point.
5. Run `git push --follow-tags` to push the new release commit and tag.

Keep an eye on the [release workflow](https://github.com/kieranpotts/resume/actions/workflows/release.yaml).
It will automatically create a release at the tag point. The pipeline will
compile the résumé to the PDF format and attach the file to the release.

The latest release can be fetched using this URL: \
<https://github.com/kieranpotts/resume/releases/latest/download/kieran-potts-cv.pdf>.
