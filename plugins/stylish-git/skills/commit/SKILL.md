---
name: commit
description: Write a commit message in the target repository's own voice - conventions measured from its history, never assumed
tools: Bash, Read, Grep
---

# Commit

Analyze the staged changes and write a commit message that matches **this repository's** history.

Two layers, answering different questions:

| Layer | Question | Source |
|---|---|---|
| **Observed** | What does a commit here *look like*? | Measured from the repo's own history |
| **Invariant** | What belongs *in* a commit rather than somewhere else? | Argued from how the history is consumed |

Nothing about form is declared in this skill. The governing rule:

> **Never invent a convention the repository does not already have.**

If it does not use scopes, do not attach one. If its subjects run long, do not truncate them to fit a limit borrowed from elsewhere.

## Layer 1 - Measure the repository

### 1. Build a clean sample

```bash
N=400
S=$(mktemp)
git log --no-merges -n "$N" --pretty=format:'%an%x09%ae%x09%s' \
  | awk -F'\t' '$1 !~ /\[.*[Bb]ot.*\]|[-_ ][Bb]ot$/ && $2 !~ /\[.*bot.*\]|bot@|actions@github\.com/' > "$S"
cut -f3 "$S" > "$S.subj"

wc -l < "$S"                                              # usable sample size
awk -F'\t' '{print $1}' "$S" | sort | uniq -c | sort -rn | head -5   # authors
```

**Pitfalls. Each of these has produced a wrong reading in practice:**

- **Bots.** A mainline that is half automated version bumps halves every ratio you compute. The filter above catches the common naming patterns; the author histogram is printed so you can spot the ones it misses and re-filter by name.
- **Merge commits.** `--no-merges` is not optional - nobody wrote those subjects.
- **Squash detection.** Do not conclude "squash-merged" from a `(#N)` subject suffix. Whether it appears depends on the PR title convention, so it can be absent in a repo that squashes every PR. Use parent counts, and treat `(#N)` as a secondary signal only.

### 2. Read the axes

```bash
T=$(wc -l < "$S"); pct() { awk -v t="$T" '{n++} END {printf "%d%%\n", (t?100*n/t:0)}'; }

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

# body usage. \001 as the record separator, because awk reads RS="\0" as paragraph mode
git log --no-merges -n "$N" --pretty=format:'%x01%b' \
  | awk 'BEGIN{RS="\001"} NR>1 {t++; s=$0; gsub(/^[ \n]+|[ \n]+$/,"",s); if (s!="") {w++; print split(s,a,"\n") > "/dev/stderr"}} END {printf "with body          : %d%%\n", (t?100*w/t:0)}' 2>"$S.body"
sort -n "$S.body" | awk '{v[NR]=$1} END {if (NR) printf "body lines present : median %d\n", v[int((NR+1)/2)]}'

# how branch work lands on the mainline
git log -n "$N" --pretty=format:'%p' | awk '{c[NF]++} END {for (k in c) printf "%s-parent: %d\n", k, c[k]}'
```

What each measurement decides:

| Measurement | Decision |
|---|---|
| non-ascii ratio | the language of the subject - follow the majority, do not translate the repo |
| conventional prefix ratio | whether to use a `type:` prefix at all. Low ratio means the repo writes plain subjects; write one |
| scoped ratio + scope list | whether to attach a scope, and which scope vocabulary actually exists here |
| starts-uppercase, trailing period | capitalization and punctuation |
| length median and p90 | the length to aim for and the ceiling. There is no fixed character limit |
| type list | the type vocabulary. Use what appears; never import types the repo has never used |
| with-body %, median body lines | **one-directional**: if bodies are essentially absent, do not write one. A repo that has bodies does not oblige you to add one - Layer 2 decides that |
| parent counts | how branch work lands. A meaningful share of 2-parent commits means merge commits preserve branch history; nearly all 1-parent means squash or rebase discards it |
| `(#N)` suffix ratio | that suffix is added by the merge, not by the author. **Never fabricate one** - at commit time the number does not exist yet |

### 3. When the sample is too small

Below roughly 20 human commits there is no convention to observe. Say so and ask the user which convention to follow. Do not fill the gap with a default.

## Layer 2 - Invariants

Form belongs to the repository. Placement does not. These four hold in any repository, and each is argued from mechanics rather than taste.

### 1. Never write a bullet list of the sub-changes

Whichever merge style the repo uses, that list carries no information:

- **Squash or rebase repo** - branch commit messages are discarded at merge. The list is written to be thrown away.
- **Merge-commit repo** - those commits are already in the history, individually. The list duplicates them.

There is no repo shape in which the reader gains something `git log` would not already give them.

### 2. A body only when there is a constraint to preserve, about three lines

A commit body is read at `git blame` time, not at review time. Its reader is someone about to change this code, asking what they must not break. So write a body only when such a constraint exists:

- an ordering or timing requirement the diff does not show
- an upstream bug or API limitation being worked around
- a deliberate trade-off a future editor would otherwise "fix" back

If nothing in that class exists, the subject alone is the entire message.

### 3. Evidence goes to the review surface - when one exists

Measurements, sample sizes, verification output, alternatives considered, rollout notes: these are review-time artifacts and belong in the PR/MR description.

**Conditional.** With no review surface the commit is the only record, and this rule is void - keep the reasoning in the commit. Detect it:

```bash
[ -d .github ] || [ -d .gitlab ] || git log -n 200 --pretty=format:'%s' | awk '/\(#[0-9]+\)$|![0-9]+$/'
```

### 4. Draft the review-surface description before committing

This is the actual mechanism behind bloated commit messages: at commit time the PR does not exist yet, so the reasoning has nowhere to go and gets parked in the commit. Give it a home first, and the commit ends up short because everything else already has a place. Skip when rule 3 is void.

## Process

1. **Stage selectively.** Read `git status --porcelain`, then stage the files this task actually
   changed, naming each path. Never `git add -A` and never `git add .` - a working session leaves
   stray untracked files behind (tool and MCP configuration, editor state, scratch output), and a
   blanket add sweeps them into the commit. Report anything you deliberately left unstaged so the
   user can see what was excluded and why.
2. `git diff --staged`. If it is empty, stop and say so.
3. Run Layer 1 against this repository and report the measured profile before proposing anything.
4. Compose the subject in the measured form: language, prefix style, scope usage, case, length target.
5. Decide the body by Layer 2 - a constraint gets up to about three lines, otherwise no body. Never a bullet list.
6. If a review surface exists and this work becomes a PR, draft that description first.
7. Present the message, then the ready-to-run command.

Stage only what this task touched, and never push. Committing is the user's call unless they have already authorized it.

## Output

Report what was measured, then the message:

```text
profile: <language> · <prefix style> · scope <N>% · <case> · length median <M> p90 <P> · <merge style>

<subject>

<body, only when a constraint was recorded>
```

Then the commit command in a shell block for the user to run.
