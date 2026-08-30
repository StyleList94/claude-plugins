#!/usr/bin/env bash
# Measure this repository's commit conventions from its own history.
#
# Lives in a script rather than in SKILL.md on purpose: skill bodies are passed
# through slash-command argument substitution, which rewrites every $0..$9 it
# finds. awk field references are exactly that shape, so an invocation carrying
# arguments would silently replace $1/$2 with the argument text and the
# measurements would come back plausible and wrong. Script files are not
# substituted.
#
# Usage: commit-profile.sh [-n SAMPLE] [-x EXTRA_BOT_REGEX]
#   -n  commits to sample (default 400)
#   -x  additional author-name regex (POSIX ERE) to exclude, for bots the
#       default filter misses. Read the author histogram below and re-run with
#       it when one shows up.

set -u

N=400
export EXTRA_BOT=''

while getopts ':n:x:' opt; do
  case "$opt" in
    n) N=$OPTARG ;;
    x) EXTRA_BOT=$OPTARG ;;
    *) echo "usage: $(basename "$0") [-n SAMPLE] [-x EXTRA_BOT_REGEX]" >&2; exit 2 ;;
  esac
done

git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repository" >&2; exit 1; }

S=$(mktemp)
trap 'rm -f "$S" "$S.subj" "$S.body"' EXIT

# The bot filters stay written as awk regex literals. Passing them through
# `awk -v` would run escape processing over the value and turn `\[` into `[`,
# which silently widens the pattern into one that excludes every author.
# Only the caller-supplied pattern is variable, and it arrives via ENVIRON,
# which does no escape processing.

# 1. Build a clean sample -----------------------------------------------------
git log --no-merges -n "$N" --pretty=format:'%an%x09%ae%x09%s' \
  | awk -F'\t' 'BEGIN {ex = ENVIRON["EXTRA_BOT"]}
      $1 !~ /\[.*[Bb]ot.*\]|[-_ ][Bb]ot$/ &&
      $2 !~ /\[.*bot.*\]|bot@|actions@github\.com/ &&
      (ex == "" || $1 !~ ex)' > "$S"
cut -f3 "$S" > "$S.subj"

T=$(wc -l < "$S" | tr -d ' ')
echo "sample             : $T human commits (of $N scanned)"

if [ "$T" -lt 20 ]; then
  echo
  echo "Below ~20 human commits there is no convention to observe."
  echo "Ask the user which convention to follow; do not fill the gap with a default."
  echo
  echo "authors:"
  awk -F'\t' '{print $1}' "$S" | sort | uniq -c | sort -rn | head -5
  exit 0
fi

echo "authors:"
awk -F'\t' '{print $1}' "$S" | sort | uniq -c | sort -rn | head -5
echo

# 2. Read the axes ------------------------------------------------------------
pct() { awk -v t="$T" '{n++} END {printf "%d%%\n", (t?100*n/t:0)}'; }

printf 'non-ascii subject  : '; LC_ALL=C awk '/[\200-\377]/'       "$S.subj" | pct
printf 'conventional prefix: '; awk '/^[A-Za-z]+(\([^)]*\))?!?: /' "$S.subj" | pct
printf 'scoped             : '; awk '/^[A-Za-z]+\([^)]*\)!?: /'    "$S.subj" | pct
printf 'starts uppercase   : '; sed 's/^[A-Za-z]*([^)]*)!*: //; s/^[A-Za-z]*!*: //' "$S.subj" | awk '/^[A-Z]/' | pct
printf 'trailing period    : '; awk '/\.$/'                        "$S.subj" | pct
printf 'PR ref suffix      : '; awk '/\(#[0-9]+\)$/'               "$S.subj" | pct

# subject length in characters, not bytes
LC_ALL=C awk '{s=$0; gsub(/[\300-\377][\200-\277]*/,"x",s); print length(s)}' "$S.subj" \
  | sort -n | awk '{v[NR]=$1} END {printf "length             : median %d  p90 %d\n", v[int((NR+1)/2)], v[NR<10?NR:int(NR*0.9)]}'

# the vocabulary actually in use here - not a list carried in from elsewhere
echo "types:";  sed -n 's/^\([A-Za-z][A-Za-z]*\)\(([^)]*)\)\{0,1\}!\{0,1\}:.*/\1/p' "$S.subj" | sort | uniq -c | sort -rn | head -8
echo "scopes:"; sed -n 's/^[A-Za-z][A-Za-z]*(\([^)]*\))!\{0,1\}:.*/\1/p'             "$S.subj" | sort | uniq -c | sort -rn | head -8

# body usage. Carries author and email so the SAME filter applies, and strips trailers.
git log --no-merges -n "$N" --pretty=format:'%x01%an%x02%ae%x02%b' \
  | awk 'BEGIN {RS="\001"; FS="\002"; ex = ENVIRON["EXTRA_BOT"]} NR>1 {
      if ($1 ~ /\[.*[Bb]ot.*\]|[-_ ][Bb]ot$/ ||
          $2 ~ /\[.*bot.*\]|bot@|actions@github\.com/ ||
          (ex != "" && $1 ~ ex)) next
      t++; n=split($3, L, "\n"); b=""
      for (i=1;i<=n;i++) if (tolower(L[i]) !~ /^(co-authored-by|signed-off-by|co-committed-by):/) b = b L[i] "\n"
      gsub(/^[ \n]+|[ \n]+$/,"",b)
      if (b != "") {w++; print split(b,a,"\n") > "/dev/stderr"}
    } END {printf "with body          : %d%% (of %d)\n", (t?100*w/t:0), t}' 2>"$S.body"
sort -n "$S.body" | awk '{v[NR]=$1} END {if (NR) printf "body lines present : median %d\n", v[int((NR+1)/2)]}'

# how branch work lands on the mainline
git log -n "$N" --pretty=format:'%p' | awk '{c[NF]++} END {for (k in c) printf "%s-parent: %d\n", k, c[k]}'
