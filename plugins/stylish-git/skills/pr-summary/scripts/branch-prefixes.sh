#!/usr/bin/env bash
# Report the branch-name prefixes actually in use on the remote.
#
# Lives in a script rather than in SKILL.md because skill bodies are passed
# through slash-command argument substitution, which rewrites every $0..$9 it
# finds. `print $1` is exactly that shape.

set -u

git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repository" >&2; exit 1; }

out=$(git branch -r --format='%(refname:short)' | sed 's@^origin/@@' \
  | awk -F/ 'NF>1 {print $1}' | sort | uniq -c | sort -rn | head -8)

# An empty result is not "this repo has no prefix convention" - it is far more
# often "the remote keeps no merged branches to measure". Saying so is the whole
# point: a silent zero-line output reads as an observation, and the caller would
# draw a conclusion the data does not support.
if [ -z "$out" ]; then
  echo "no prefixed remote branches to measure."
  echo "This is unobservable here, not absent - the repo most likely deletes branches after merge."
  echo "Do not conclude the repo has no prefix convention. Recover it from merged PRs instead:"
  echo "  gh pr list --state all --limit 20 --json headRefName --jq '.[].headRefName'"
  exit 0
fi

printf '%s\n' "$out"
