---
name: code-review
description: Interactive code review walkthrough. Use this whenever the user wants to review their changes (a PR or a local diff) and decide each finding interactively — apply, modify, defer, or dismiss. Auto-detects PR for current branch, falls back to local diff. Unlike a one-shot review, this surfaces every finding regardless of confidence score and walks the user through them one-by-one. Trigger phrases include "review my changes", "walk me through the review", "go through findings one by one", "interactive review", "review my PR", "check my diff".
argument-hint: "[PR-number] [--local]"
tools: Bash, Read, Edit, Glob, Grep, AskUserQuestion, TaskCreate, TaskUpdate, Agent
---

# Interactive Code Review

Run the full 5-agent code review pipeline on a diff (PR or local), surface every finding regardless of confidence score, and walk the user through each one with an apply/modify/defer/dismiss decision.

This is intentionally different from `/code-review:code-review`, which filters findings by confidence (≥80) and posts results as a PR comment. This skill keeps every finding and lets the developer make the call per item.

## Why this exists

Filtered, comment-only review is great for sign-off, but it discards findings that may matter and gives the developer no easy way to act on them. This skill assumes the developer is in the loop and wants to triage each finding with full context.

## Step 1 — Detect input mode

Parse the invocation arguments:

- If args contain a numeric token → **PR mode** with that PR number. Fetch the diff via `gh pr diff <N>`.
- If args contain `--local` → **force local mode** (skip auto-detection).
- Otherwise auto-detect:
  1. Check that `gh` is installed and the working directory is inside a GitHub repo. If either check fails, fall back to local mode silently.
  2. Run `gh pr view --json number 2>/dev/null`. If it returns a number, that's the open PR for the current branch → **PR mode** with that number.
  3. If no PR is found → **local mode**.

For local mode, detect the base branch by trying `main`, then `master`, then `develop`, in that order. Use the first one that exists locally or on the remote (`git rev-parse --verify <name>` or `git rev-parse --verify origin/<name>`). If none exist, ask the user via AskUserQuestion which branch to diff against.

Print a one-line banner so the user can sanity-check the detected mode before the heavy work begins. Examples:

```
📍 PR #42 review mode (auto-detected)
📍 Local diff review mode (main..HEAD, 12 files)
```

## Step 2 — Pre-flight

Compute the diff:

- PR mode: `gh pr diff <N>`
- Local mode: `git diff <base>..HEAD`

Then:

- If the diff is empty, exit with a friendly message: `No changes to review.` and stop.
- If the diff exceeds ~5000 lines, warn the user and confirm via AskUserQuestion before proceeding. Large diffs cost a lot of agent runs; the user should opt in.
- Dispatch a single Haiku agent to collect the **paths** (not contents) of relevant CLAUDE.md files: the repo root CLAUDE.md (if present) and any CLAUDE.md inside directories whose files were modified. The reviewers will read these directly when they need them.

## Step 3 — Five parallel review agents (Sonnet)

Dispatch all five reviewers in parallel — one message, five Agent tool calls. Each reviewer returns a flat list of findings shaped like:

```json
[
  {
    "file": "path/to/file.ts",
    "line_range": "42-47",
    "category": "bug | claude-md | history | comments | past-prs",
    "description": "<one paragraph>",
    "evidence": "<quoted code or doc snippet>"
  }
]
```

| # | Reviewer role | Category tag | Notes |
|---|---|---|---|
| 1 | CLAUDE.md compliance | `claude-md` | Pass the CLAUDE.md paths from Step 2. Verify each cited rule actually appears in those files before flagging. |
| 2 | Shallow bug scan | `bug` | Read only the changed lines plus minimal surrounding context. Focus on real bugs that will bite at runtime. Skip nitpicks. |
| 3 | Git blame & history | `history` | Read `git log -p` and `git blame` for the modified regions. Flag changes that conflict with documented past intent. |
| 4 | Inline comment guidance | `comments` | Read inline comments and JSDoc/TSDoc near the changes. Flag changes that violate directives written there. |
| 5 | Past-PR comment patterns | `past-prs` | **PR mode only.** Read recent PR comments on the modified files via `gh pr list --state merged` + `gh pr view <N> --comments`. Skip entirely in local mode. |

Each reviewer must ignore these false-positive classes (same as the official pipeline):

- Pre-existing issues unrelated to this diff
- Things a linter, typechecker, or CI step would catch
- Changes outside the modified line ranges
- Pedantic style nitpicks not called out in CLAUDE.md or inline comments
- Changes that look intentional in context (refactors, deletions)
- Issues silenced explicitly in the code (lint-ignore, eslint-disable, etc.)

## Step 4 — Confidence scoring (parallel Haiku)

For every finding from Step 3, dispatch one Haiku agent in parallel that returns a single integer score on the official 0/25/50/75/100 rubric:

- **0** — Not confident at all. False positive or pre-existing issue.
- **25** — Somewhat confident. Might be real, might be a false positive; couldn't verify.
- **50** — Moderately confident. Real issue but probably a nitpick or low-impact in context.
- **75** — Highly confident. Real issue likely to bite in practice, or directly mentioned in a relevant CLAUDE.md.
- **100** — Absolutely certain. Confirmed real, will happen frequently.

Attach the score to the finding as metadata. **Do not filter.** The goal is to inform the user's decision in Step 8, not to drop anything.

## Step 5 — Normalize the finding list

- Dedupe near-duplicates: findings on the same `file` whose `line_range` overlaps (or is within 3 lines) and whose descriptions describe the same issue → keep the one with the highest score, merge the others' evidence into the kept finding.
- Sort by score descending. Ties broken by file path then line number.
- If the resulting list has more than 30 findings, ask the user via AskUserQuestion: `View all`, `Top 30 only` (drop the rest for this run), or `Abort`.

## Step 6 — Pre-analysis (parallel Haiku)

For every surviving finding, dispatch one Haiku agent in parallel that:

1. Uses Read to load the relevant lines of the file as they exist right now.
2. Returns a structured pre-analysis:

```json
{
  "validity_assessment": "seems valid | partially valid | questionable | likely false positive",
  "suggested_fix": {
    "before": "<current code>",
    "after": "<proposed code>",
    "rationale": "<one sentence>"
  } | null
}
```

`suggested_fix` should be `null` only when there is no concrete change to propose (e.g. the finding is purely informational). The before/after must be small and focused — just the lines that change.

## Step 7 — Bulk task creation

For each finding, call TaskCreate with:

- **subject** — `[score=NN] file:line — short description` (keep under ~80 chars; truncate the description if needed)
- **description** — full body containing:
  - Category
  - Original finding description and evidence
  - Pre-analysis validity assessment
  - Suggested fix (before/after with rationale), or "no actionable fix" if null
- **activeForm** — `Reviewing <category> finding in <file>`

Tasks start as `pending`. Don't set `in_progress` here — the loop in Step 8 does that one at a time.

## Step 8 — Sequential walkthrough loop

Iterate the tasks in score-descending order. For each task:

1. `TaskUpdate(taskId, status: in_progress)`.
2. Display to the user, in this order:
   - Score and category
   - The original finding description and evidence
   - The pre-analysis validity assessment
   - The suggested fix as a clean before/after diff (use markdown fenced code blocks)
3. Ask via AskUserQuestion (4 options, single-select):
   - **Apply** — Apply the suggested fix as-is.
   - **Modify and apply** — User wants to tweak the fix before applying.
   - **Defer** — Leave this for later; move on.
   - **Dismiss as false positive** — This finding is wrong; close it.
4. Branch on the answer:
   - **Apply** — Re-Read the file (line-shift guard, see below). Use Edit with the suggested before/after. `TaskUpdate(taskId, status: completed)`.
   - **Modify and apply** — Ask the user via AskUserQuestion (or free-text follow-up) what to change. Construct a revised before/after, Edit, then `TaskUpdate(taskId, status: completed)`.
   - **Defer** — Leave the task at `in_progress`. Move to the next finding. The deferred task will remain visible in TaskList for follow-up across sessions.
   - **Dismiss as false positive** — `TaskUpdate(taskId, status: completed, metadata: {dismissed: true})`.

### Line-shift guard

Earlier fixes in the same file may have shifted line numbers. Before any Edit:

1. Re-Read the file region.
2. Verify the original `before` text still exists at the expected location.
3. If not, search the file for the `before` text by exact match. If found exactly once, use that location and proceed.
4. If found zero or more than one time, stop and tell the user the line shifted. Offer two choices: `Skip this finding` or `Open the file for manual edit` (just print the path and line range so the user can act in their editor).

Never silently apply an Edit when the location is uncertain.

## Step 9 — Wrap-up

After the loop ends, print a single summary block:

```
🔍 Review complete
  ✅ Applied:   N
  🚫 Dismissed: M
  ⏸️  Deferred:  K  (still in TaskList)
```

Don't write any report file. Deferred items remain `in_progress` in TaskList; the user can resume them later or in a future session.

## Edge cases reference

| Case | Handling |
|---|---|
| Empty diff | Exit with `No changes to review.` |
| Diff > 5000 lines | Warn and confirm before continuing |
| > 30 findings after normalization | Ask: View all / Top 30 only / Abort |
| `gh` CLI not installed | Silent fallback to local mode |
| No `main`/`master`/`develop` branch | Ask user for the base branch |
| A reviewer agent returns nothing | Proceed with whatever the others found |
| Line-shift makes Edit ambiguous | Stop, offer skip or manual edit |
| User aborts via Ctrl+C mid-loop | Deferred items stay in TaskList; no cleanup needed |

## Why the design looks like this

- **Five reviewers in parallel** — each one specializes in a different signal (codebase rules, runtime bugs, history, comments, social context). Catching them in parallel agents avoids one reviewer's blind spot dominating the result.
- **Scoring kept but not used as a filter** — score is the most useful single piece of metadata for the user's decision, but it's a confidence estimate, not ground truth. Filtering on it (as the official skill does) is right for automated PR comments but wrong for an interactive walkthrough where the user is the final judge.
- **Pre-analysis before asking** — handing the user "here's the issue, here's whether I think it's real, here's exactly what I'd change" turns each prompt into a quick yes/no instead of a research task.
- **Immediate apply** — applying fixes per-finding keeps the working state simple and lets the line-shift guard run once per Edit instead of trying to merge a batch at the end.
- **Defer leaves tasks in_progress** — task state doubles as the persistence layer for "things I haven't decided yet", with no extra report file to manage.
