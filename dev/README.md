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

