#!/bin/bash
SEMANTIC_VERSIONING_REGEX="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$"
CONVENTIONAL_COMMIT_REGEX="^(build|chore|ci|docs|feat|fix|refactor|style|test)(\((.+)\))?(\!)?:\s([^\s].*)$"

LAST_TAG=$(git describe --abbrev=0 --tags 2>&1)
UPDATED="false"

if [[ $LAST_TAG =~ $SEMANTIC_VERSIONING_REGEX ]]
then
  MAJOR=${BASH_REMATCH[1]}
  MINOR=${BASH_REMATCH[2]}
  PATCH=${BASH_REMATCH[3]}
  echo "Starting with $MAJOR.$MINOR.$PATCH"
else
  echo "Last tag has incorrect versioning format: $LAST_TAG"
  exit 1
fi

LAST_TAGGED_COMMIT=$(git rev-list -n 1 "$LAST_TAG")
COMMITS_SINCE_LAST_TAG="$(git rev-list "$LAST_TAGGED_COMMIT"..HEAD --reverse)"

for COMMIT in $COMMITS_SINCE_LAST_TAG
do
  MESSAGE=$(git log -n 1 "$COMMIT" --pretty=%s)

  if [[ $MESSAGE =~ $CONVENTIONAL_COMMIT_REGEX ]]
  then
    TYPE=${BASH_REMATCH[1]}
    BREAKING=${BASH_REMATCH[4]}
  else
    echo "$MESSAGE -> Commit message does not match conventional commit format!"
    exit 1
  fi

  if [[ $BREAKING == "!" ]]
  then
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    UPDATED="true"
    echo "$MESSAGE -> $MAJOR.$MINOR.$PATCH"
    continue
  fi

  case $TYPE in
    build|chore|ci|fix|refactor)
      PATCH=$((PATCH + 1))
      UPDATED="true"
      echo "$MESSAGE -> $MAJOR.$MINOR.$PATCH"
      ;;
    feat)
      MINOR=$((MINOR + 1))
      PATCH=0
      UPDATED="true"
      echo "$MESSAGE -> $MAJOR.$MINOR.$PATCH"
      ;;
    docs|style|test)
      echo "$MESSAGE -> $MAJOR.$MINOR.$PATCH"
      ;;
  esac

done

echo "updated=$UPDATED"
echo "version=$MAJOR.$MINOR.$PATCH"
