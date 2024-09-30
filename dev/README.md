# Notes for Bathtub Developers

## Branches
The Bathtub repository has a number of special persistent branches.
* `main` -- The default trunk branch.
  Contains complete `src/`, and `test/`, and `dev/` directories.
  Contains a minimal `docs/` directory.
  Contains the version of `README.md` displayed on Bathtub's GitHub home page.
* `pages` -- The branch for the web page <https://williaml33moore.github.io/bathtub/>, also available at <https://bathtubbdd.dev/>.
  Contains a custom, minimal `README.md`.
  Contains complete `src/` and `test/` directories merged in from `main`.
  These directories are only for citation purposes, so web pages can link to Bathtub source files, e.g., <https://github.com/williaml33moore/bathtub/blob/pages/src/bathtub_vip.f>.
  Contains a complete `docs/` directory with the source code for the web page and blog.
  Do _not_ merge `docs/` into `main`.
  `main` is for code; `pages` is for the web page.
* `release` -- The branch for preparing GitHub releases.
  Releases consist of the directories and files that are [tagged](https://github.com/williaml33moore/bathtub/tags) in Git and packaged for users to download from the Bathtub [releases](https://github.com/williaml33moore/bathtub/releases) page.
  Contains a version of `README.md` customized for user downloads.
  Contains a complete `src/` directory and a minimal `docs/` directory.
  Omits `test/` and `dev/`.
  Most of the time, `release` represents the state of the latest release.
* `tagged/main/vX.Y.Z` -- Branches for continued development on release tags.
  Release tags start with `v` and follow the [semantic versioning](https://semver.org/) numbering format.
  Everytime `release` minus `test/` and `dev/` is tagged with `vX.Y.Z`, tag `main` plus `test/` and `dev/` with matching tag `main/vX.Y.Z`.
  This way, `test/` and `dev/` get parallel tags that relate to the releases.
  Then, create a branch `tagged/main/vX.Y.Z` based on tag `main/vX.Y.Z`.
  The idea is that `src/` is tagged immutably, but `test/` and `dev/` are part of a mutable branch so, for example, we could add or modify tests in `test/` that are specific to `vX.Y.Z`.
  In other words, we freeze and tag the source, but test development and maintenance can always continue.

### Procedures and Guidelines
Bathtub code development follows the [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow).
Create feature branches from `main`, ideally tied to an [issue](https://github.com/williaml33moore/bathtub/issues).
When the feature work is done, create a [pull request](https://github.com/williaml33moore/bathtub/pulls) to merge the feature branch back into `main`.
Delete the feature branch when the pull request is completed.

Similarly, in parallel, to change the website, create a feature branch from `pages`.
The feature branch should be tied to an [issue](https://github.com/williaml33moore/bathtub/issues), particularly functional changes to Jekyll layouts.
Content changes like blog posts can also be tied an issue.
It's a good idea to merge `main` into the feature branch, so the web page has access to the latest source code files.
For example, if there's a new source file in `main` that you want to write a blog post about, you want that new source file also to be in your `pages` feature branch for reference.
When the feature work is done, create a [pull request](https://github.com/williaml33moore/bathtub/pulls) to merge the feature branch back into `pages`.
Delete the feature branch when the pull request is completed.
GitHub automatically [rebuilds](https://github.com/williaml33moore/bathtub/actions) the web page every time there's a pull request, commit, or push to `pages`.

_Do_ merge `main` into `pages` from time to time.
_Do not_ merge `pages` back into `main` ever.
We do not want web content and blog posts in `main`.

When it's time to tag and release, it's fine to work directly in the `release` branch.

__Important:__ In `main`, edit file `vip-spec.sv` and update the `version:` number to the new version you want to create, and commit the change.

Merge `main` into `release`.
Make sure `release` does not have `test/`, `dev/`, or the test file `pytest.ini`.
```sh
git fetch origin --tags
git checkout release
git pull # Do what's necessary to get working directory clean
git merge main
git rm -r test dev pytest.ini # Errors are fine if dirs are missing or unmanaged
git commit
```
The tagging procedures are detailed below.
When the tag is done, push `release` to origin.

When `release` is tagged with a new tag `vX.Y.Z`, apply a matching tag to `main`, then create a new `tagged/main` branch.
```sh
git fetch origin --tags
git checkout main
git tag -a main/vX.Y.Z -m "Release version X.Y.Z"
git push main/vX.Y.Z
git branch tagged/main/vX.Y.Z
git push tagged/main/vX.Y.Z
```
Do not commit changes into the `src/` directory of a tagged `main/vX.Y.Z` branch.
The intent is that the `src/` directory should stay unchanged from the matching tag.
Do feel free to commit changes into the `test/` and `dev/` directories, for example, to add retroactively new tests or modify old tests that apply to the source code tagged `vX.Y.Z`.

## Tags
The Bathub repository contains the following tags, where "X.Y.Z" follows the [semantic versioning](https://semver.org/) numbering format.
* `vX.Y.Z` -- The tag used to create a GitHub [release](https://github.com/williaml33moore/bathtub/releases/new).
* `main/vX.Y.Z` -- A snapshot of the `main` branch when release `vX.Y.Z` was created.
* `pages/vX.Y.Z` -- A snapshot of the `pages` branch when release `vX.Y.Z` was created.

### Procedures and Guidelines
Follow the procedures above to prepare the `release` branch in a working directory.
Get the working directory clean, i.e., no outstanding commits or unmodified files.
```sh
$ git status
# On branch release
nothing to commit, working directory clean
```
Run whatever tests you deem necessary in the working directory to validate the code prior to the release.
To run tests, temporarily checkout directory `test/` and file `pytest.ini`, but do not commit them to the branch.

To run the latest tests, check out the test artifacts from `main`:
```sh
git reset
git checkout main -- pytest.ini test
pytest
```

To run compatibility tests, check out the test artifacts from the tagged `main` branch from an earlier tag. In this example, `vX.Y.0` represents a version earlier than `vX.Y.Z`, and you are testing that `vX.Y.Z` source doesn't break earlier `vX.Y.0` tests.
```sh
git reset
git checkout tagged/main/vX.Y.0 -- test pytest.ini
pytest
```
Repeat with as many prior releases as necessary.
For example, you might also test against `tagged/main/vX.0.0`.

If any tests fail, fix them in `main`, and restart the release process.
If the latest source is incompatible with an earlier release, increment the appropriate semantic versioning field in the version number.

When your tests are clean, reset your work directory to clear out your temporary test artifacts.
Double-check the version in `vip-spec.sv`, then tag the `release` branch, and push the tag and branch.
```sh
git fetch origin --tags
git reset
git status # Should be on branch release, and working directory should be clean and up-to-date
cat vip-spec.sv # Check version
git tag -a vX.Y.Z -m "Release version X.Y.Z"
git push origin vX.Y.Z release
```
Create the GitHub release at <https://github.com/williaml33moore/bathtub/releases/new>.
* Choose a tag: "vX.Y.Z"
* Previous tag: Auto or manual
* Generate release notes
* Release title: "Bathtub vX.Y.Z"
* Set as the latest release: Yes
* Create a discussion for this release: Yes
* Publish release

When the release is complete, tag `main` and `pages` with matching version tags as snapshots.
```sh
```
