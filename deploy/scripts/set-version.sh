#!/usr/bin/env bash
# One source of truth: the VERSION file. Copies it into pubspec.yaml (keeping the build number),
# backend/pyproject.toml and the Flutter fallback in app/lib/core/version.dart.
#   deploy/scripts/set-version.sh 1.2.0      (writes VERSION first), or no argument to just sync
set -euo pipefail
cd "$(dirname "$0")/../.."
[ $# -eq 1 ] && echo "$1" > VERSION
V="$(tr -d '[:space:]' < VERSION)"
[[ "$V" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]] || { echo "VERSION '$V' is not SemVer" >&2; exit 1; }
sed -i -E "s/^version: [^+ ]+(\+[0-9]+)?/version: $V\1/" app/pubspec.yaml
sed -i -E "0,/^version = \".*\"/s//version = \"$V\"/" backend/pyproject.toml
sed -i -E "s/defaultValue: '[^']*'\);\s*\/\/ VERSION/defaultValue: '$V'); \/\/ VERSION/" app/lib/core/version.dart
echo "Version is now $V"
