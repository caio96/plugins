#!/usr/bin/env bash
# Local pre-push check: validates manifests and makes sure every changed plugin
# bumped its version (installed copies only update on a version change).
# Usage: scripts/check.sh [base-ref]   (default: origin/main)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
base="${1:-origin/main}"
status=0

claude plugin validate . >/dev/null || { echo "FAIL: marketplace manifest"; status=1; }
for dir in plugins/*/; do
  name=$(basename "$dir")
  claude plugin validate "$dir" >/dev/null || { echo "FAIL: validate $name"; status=1; }

  # Committed + uncommitted changes relative to base.
  if [ -n "$(git diff --name-only "$base" -- "$dir")" ] || \
     [ -n "$(git ls-files --others --exclude-standard -- "$dir")" ]; then
    manifest="$dir.claude-plugin/plugin.json"
    new=$(jq -r .version "$manifest")
    old=$(git show "$base:$manifest" 2>/dev/null | jq -r .version 2>/dev/null || echo "none")
    if [ "$new" = "$old" ]; then
      echo "FAIL: $name changed but version is still $new"
      status=1
    else
      echo "ok:   $name $old -> $new"
    fi
  fi
done
[ $status -eq 0 ] && echo "All checks passed."
exit $status
