---
name: pr-summary
description: Generate a PR summary from the branch's commits, then copy it to the clipboard or upload it to the PR (create or update)
argument-hint: "[upload]"
tools: Bash, Read, Grep, AskUserQuestion
---

# PR Summary

Generate a pull request summary from the current branch's work and either copy it to the clipboard (default) or upload it directly (`upload` argument).

**Language rule:**
- The PR **title** follows the commit convention **measured from this repository** (see the `commit` skill, Layer 1) — it becomes the squash-merge commit subject, so it must read like the repo's own history.
- The PR **body** is written in the **user's working language** — match the language the user is conversing in, and render the section headers in that language.
- Communicate with the user in that same language.

This skill is meant to run inside a Claude-generated worktree, where the current branch is the feature branch.

## Step 1: Gather context

```bash
git_root=$(git rev-parse --show-toplevel)
branch=$(git rev-parse --abbrev-ref HEAD)
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

git log --oneline "origin/${default_branch}..HEAD"      # commits to summarize
git diff --stat "origin/${default_branch}...HEAD"        # changed files overview
git diff "origin/${default_branch}...HEAD"               # full diff for analysis
```

- If `branch` equals `default_branch`, or there are no commits ahead, stop and tell the user there is nothing to summarize.

## Step 2: Validate branch convention

Branch names must match `<prefix>/<kebab-case>`.

| Prefix | Purpose |
|--------|---------|
| `feature/` | New feature |
| `fix/` | Bug fix |
| `chore/` | Maintenance, refactoring |
| `docs/` | Documentation |

Regex: `^(feature|fix|chore|docs)/[a-z0-9._-]+$`

If the branch does **not** match, warn the user and suggest a compliant name based on the work. Do **not** block — continue with the summary.

## Step 3: Build the title (repository's measured commit form)

Run Layer 1 of the `commit` skill against this repository and write the title in the form it reports — language, prefix style, scope usage, case, and length target. Do not assume a convention the repo does not have.

- If the repo uses a `type` prefix, use the dominant change type across the branch, drawn from the type vocabulary the repo actually uses
- Attach a scope only if the repo scopes its subjects, and only from its existing scope vocabulary
- This is a **squash merge**, so the subject must be **comprehensive** — cover the whole branch in one line, not a single commit
- Never append a `(#N)` PR reference; the merge adds it

## Step 4: Build the body (feature-oriented)

Write the body in the **body language** (see the Language rule), and render the section headers in that language using this mapping:

| Section | Korean header | English header |
|---------|---------------|----------------|
| Summary | `## 요약` | `## Summary` |
| Related issue | `## 관련 이슈` | `## Related Issues` |
| Changes | `## 변경 사항` | `## Changes` |
| Review points | `## 리뷰 포인트` | `## Review Notes` |
| Test | `## 테스트` | `## Test Plan` |

Section order: Summary → Related issue → Changes → Review points → Test. **Always include Summary and Changes. Omit any other section that has no content.**

Example (Korean body):

```markdown
## 요약
<무엇을, 왜 — 1~3문장>

## 변경 사항
* <type>: <피처 설명>
* <type>: <피처 설명>

## 리뷰 포인트
- <리뷰어가 집중해서 볼 곳>
```

Rules:
- **Changes** — do **not** list commits one-by-one. Analyze the commits + diff and **group related changes into feature-level bullets**. Keep the `type:` prefix; write the description in the body language. Fold trivial commits (test/chore busywork) into the related feature or drop them.
- **Related issue** — include only when an issue number is detectable (e.g. `#12` in the branch name or commit messages). Use `Closes #N`. Otherwise omit the section.
- **Review points** — derive from the diff: complex logic, trade-offs, risky or wide-reaching changes. Omit if nothing is genuinely notable.
- **Test** — checklist of how to verify. Omit if not applicable.

## Step 5: Push the branch (both modes)

The branch must exist on the remote before a PR can be opened — whether the user opens it manually (copy mode) or this skill opens it (`upload` mode). Push in **both** modes.

**Safety guard — verify the upstream before pushing.** If a feature branch was created without `--no-track`, its upstream can point at `origin/<default_branch>` (e.g. `origin/main`). A bare `git push` would then push feature commits straight onto the default branch. So check the upstream first and **stop** on any mismatch.

```bash
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)

if [ -z "$upstream" ]; then
  # No upstream → create a same-named tracking branch on origin (safe)
  git push -u origin "$branch"
elif [ "$upstream" = "origin/$branch" ]; then
  # Correctly tracking its own remote branch
  git push
else
  # Mis-tracked (e.g. origin/main). Pushing here would corrupt the wrong branch — STOP.
  echo "STOP: '$branch' is tracking '$upstream', not 'origin/$branch'."
  echo "      A push would land on '$upstream' (e.g. corrupting origin/main)."
  echo "      Fix: git branch --unset-upstream   then re-run."
fi
```

Do **not** continue to the dispatch step if the guard stopped (mis-tracked upstream). Report the problem to the user and let them fix the tracking first.

## Step 6: Detect an existing PR

A PR for this branch may already be open (e.g. scope expanded after review). Detect it so the skill is idempotent — the same invocation creates a PR the first time and updates it afterward.

```bash
pr_url=$(gh pr view --json url --jq '.url' 2>/dev/null || true)   # empty when no PR exists for this branch
```

## Step 7: Dispatch by mode

**Default (no argument) — copy mode:**

Because of squash merge, put the **title at the very top** of the clipboard, then a blank line, then the body.

```bash
printf '%s\n\n%s\n' "$title" "$body" | pbcopy
```

- Print the title separately in the terminal so the user can paste it into the GitHub title field.
- Tell the user that the summary is copied and the branch is pushed. If `pr_url` is set, point them at the existing PR to paste into; otherwise tell them they can open a new PR.

**`upload` argument — create or update:**

- **No PR exists** (`pr_url` empty) → create a new one:

  ```bash
  gh pr create --base "$default_branch" --head "$branch" --title "$title" --body "$body"
  ```

- **PR already exists** (`pr_url` set) → update it. `gh pr edit` **overwrites** the body, so any manual edits or checked boxes are lost. Show the regenerated title + body and **confirm with the user before editing**. On confirmation:

  ```bash
  gh pr edit --title "$title" --body "$body"
  ```

  If the user declines the overwrite, fall back to copy mode (`pbcopy`) so they can merge the changes into the existing PR by hand.

- Report the PR URL.

## Notes

- This skill pushes the branch and summarizes (and, in `upload` mode, opens or updates the PR) — it never commits or merges.
- Title is English (commit convention); body follows the user's working language.
