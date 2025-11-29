#!/bin/bash

last_tag=$(git describe --abbrev=0 --tags 2>&1)
last_tagged_commit=$(git rev-list -n 1 "$last_tag")
commits_since_last_tag="$(git rev-list "$last_tagged_commit"..HEAD --reverse)"
for commit in $commits_since_last_tag
do
  git log -n 1 "$commit" --pretty=%s
done
