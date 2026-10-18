#!/usr/bin/env bash
set -euo pipefail

: "${RELEASE_VERSION:?RELEASE_VERSION is required}"
: "${FORGEJO_API_URL:?FORGEJO_API_URL is required}"
: "${FORGEJO_REPOSITORY:?FORGEJO_REPOSITORY is required}"
: "${FORGEJO_TOKEN:?FORGEJO_TOKEN is required}"

command -v jq >/dev/null 2>&1 || {
  echo "jq is required to create a release" >&2
  exit 1
}

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
release_notes=$("$script_directory/notes.sh")
payload=$(jq -n \
  --arg body "$release_notes" \
  --arg version "$RELEASE_VERSION" \
  --arg target_commitish "$(git rev-parse HEAD)" \
  '{body: $body, draft: false, name: $version, prerelease: false, tag_name: $version, target_commitish: $target_commitish}')

curl --request POST \
  --header 'content-type: application/json' \
  --header "Authorization: token $FORGEJO_TOKEN" \
  --data "$payload" \
  --fail \
  --show-error \
  "$FORGEJO_API_URL/repos/$FORGEJO_REPOSITORY/releases"
