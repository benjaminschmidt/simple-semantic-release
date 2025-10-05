#!/bin/bash
semantic_versioning_regex="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$"
conventional_commit_regex="^(build|chore|ci|docs|feat|fix|refactor|style|test)(\((.+)\))?(\!)?:\s([^\s].*)$"

last_tag=$(git describe --abbrev=0 --tags 2>&1)
updated="false"

if [[ $last_tag =~ $semantic_versioning_regex ]]
then
  major=${BASH_REMATCH[1]}
  minor=${BASH_REMATCH[2]}
  patch=${BASH_REMATCH[3]}
  echo "Starting with $major.$minor.$patch"
else
  echo "Last tag has incorrect versioning format: $last_tag"
  exit 1
fi

last_tagged_commit=$(git rev-list -n 1 "$last_tag")
commits_since_last_tag="$(git rev-list "$last_tagged_commit"..HEAD --reverse)"

for commit in $commits_since_last_tag
do
  message=$(git log -n 1 "$commit" --pretty=%s)

  if [[ $message =~ $conventional_commit_regex ]]
  then
    type=${BASH_REMATCH[1]}
    breaking=${BASH_REMATCH[4]}
  else
    echo "$message -> Commit message does not match conventional commit format!"
    exit 1
  fi

  if [[ $breaking == "!" ]]
  then
    major=$((major + 1))
    minor=0
    patch=0
    updated="true"
    echo "$message -> $major.$minor.$patch"
    continue
  fi

  case $type in
    build|chore|ci|fix|refactor)
      patch=$((patch + 1))
      updated="true"
      echo "$message -> $major.$minor.$patch"
      ;;
    feat)
      minor=$((minor + 1))
      patch=0
      updated="true"
      echo "$message -> $major.$minor.$patch"
      ;;
    docs|style|test)
      echo "$message -> $major.$minor.$patch"
      ;;
  esac

done

echo "updated=$updated"
echo "version=$major.$minor.$patch"
