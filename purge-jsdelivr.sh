#!/usr/bin/env bash

set -euo pipefail

REPO="wgfwpnew/wgfwp"
BRANCH="main"

mapfile -t files < <(
    git diff-tree --no-commit-id --name-only -r HEAD
)

if ((${#files[@]} == 0)); then
    echo "No changed files in the latest commit."
    exit 0
fi

echo "Purging ${#files[@]} changed file(s):"

failed=0

for file in "${files[@]}"; do
    url="https://cdn.jsdelivr.net/gh/$REPO@$BRANCH/$file"

    echo
    echo "→ $file"
    echo "  $url"

    if curl -fsS "https://purge.jsdelivr.net/gh/$REPO@$BRANCH/$file"; then
        echo
        echo "  ✓ Purged"
    else
        echo
        echo "  ✗ Purge failed"
        failed=1
    fi
done

echo

if ((failed)); then
    echo "One or more purges failed."
    exit 1
else
    echo "✓ Done!"
fi
