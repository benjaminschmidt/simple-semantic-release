# simple-semantic-release

This is a very basic script for determining the next version number based on conventional commits since the last
version tag. It can be used with forgejo actions and part of it should also work in github actions or gitea actions.
Check [https://www.conventionalcommits.org/](https://www.conventionalcommits.org/) for more details on conventional
commits.

# Just determining the next version

This should work for all forgejo actions, gitea actions, and github actions. I run versions of the following to check
that all commits on a pull request are correctly formatted and what the next version would be.

```yaml
---
name: Pull request pipeline
on:
  pull_request:
    branches:
      - main

jobs:
  check-conventional-commits:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository code
        uses: actions/checkout@v5
        with:
          fetch-depth: 0
      - name: Obtain next version
        uses: https://github.com/phaib/simple-semantic-release@latest
        with:
          create-release: false
```

# Creating a release

This only works for forgejo actions, but it shouldn't be difficult to extend this to either github or gitea.

```yaml
name: Release pipeline
on:
  push:
    branches:
      - main

jobs:
  create-release:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository code
        uses: actions/checkout@v5
        with:
          fetch-depth: 0
      - name: Obtain next version
        uses: https://github.com//phaib/simple-semantic-release@latest
        with:
          create-release: true
```

# Which type creates which version change

* feat: Increases minor version
* build: Increases patch version
* chore: Increases patch version
* ci: Increases patch version
* fix: Increases patch version
* refactor: Increases patch version
* docs: No version change, no release created
* style: No version change, no release created
* test: No version change, no release created
* Using an exclamation mark after the type and scope creates a new major version.
