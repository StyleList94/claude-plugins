#!/usr/bin/env bash
# Report the branch-name prefixes actually in use on the remote.
#
# Lives in a script rather than in SKILL.md because skill bodies are passed
# through slash-command argument substitution, which rewrites every $0..$9 it
# finds. `print $1` is exactly that shape.

set -u

git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repository" >&2; exit 1; }

git branch -r --format='%(refname:short)' | sed 's@^origin/@@' \
  | awk -F/ 'NF>1 {print $1}' | sort | uniq -c | sort -rn | head -8
