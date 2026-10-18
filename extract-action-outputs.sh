#!/usr/bin/env bash
set -euo pipefail

output_file=${1:?Usage: extract-action-outputs.sh OUTPUT_FILE}

grep -E '^(updated=(true|false)|version=[0-9]+\.[0-9]+\.[0-9]+)$' "$output_file"
