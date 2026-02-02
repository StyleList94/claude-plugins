---
description: Squash commits on branch like GitHub PR squash merge
---

# Squash Commits

Squash multiple commits into a single commit with GitHub PR squash merge style message.

## Use Case

- Clean up commits before PR merge
- Combine multiple WIP commits into one
- Maintain clean commit history

## Arguments

| Argument | Description                          | Default |
|----------|--------------------------------------|---------|
| (none)   | All commits from base branch         | -       |
| `<N>`    | Squash only last N commits           | -       |

## Commit Message Format

Same format as GitHub PR squash merge:

```text
<user-provided title>

* <commit1 message> (oldest)
* <commit2 message>
* <commit3 message> (newest)
```

## Process

1. **Safety check**: Prevent running on protected branches (main, master, develop)
2. **Detect range**:
   - No argument: Find merge base with `git merge-base origin/<base> HEAD`
   - Numeric argument: Use `HEAD~N`
3. **Show commits**: Display commits to squash (chronological order)
4. **Get title**: Ask user for commit title (using AskUserQuestion)
5. **Build message**: Generate title + commit list body
6. **Execute squash**: `git reset --soft <target> && git commit`
7. **Done**: Show push instructions (user pushes manually)

## Execution Steps

1. Get current branch with `git rev-parse --abbrev-ref HEAD`
2. Check if protected branch (main, master, develop)
3. Detect base branch (main or master)
4. Determine squash target:
   - No argument: `git merge-base origin/<base> HEAD`
   - Argument N: `HEAD~N`
5. Show commits with `git log --oneline --reverse <target>..HEAD` (chronological)
6. Ask user for commit title (using AskUserQuestion)
7. Build commit message:

   ```text
   <title>

   * <commit1 subject>
   * <commit2 subject>
   ...
   ```

8. Run `git reset --soft <target>`
9. Run `git commit` with HEREDOC for message
10. Show completion message and push instructions

## Safety Features

- **Protected branches**: Never squash on main/master/develop
- **No auto-push**: Only squash, user pushes manually

## Examples

**Squash all commits:**

```text
/stylish-git:squash

-> Current branch: feature/add-button
-> Base branch: main
-> Commits to squash (3):
   1. abc1234 feat: add button component
   2. def5678 fix: button style
   3. ghi9012 refactor: clean up

-> Enter commit title: feat: add button component with styling

-> Squashing...
-> Squashed 3 commits

-> Final commit message:
   +----------------------------------------
   | feat: add button component with styling
   |
   | * feat: add button component
   | * fix: button style
   | * refactor: clean up
   +----------------------------------------

-> Run 'git push --force-with-lease' to update remote
```

**Squash last N commits:**

```text
/stylish-git:squash 2

-> Current branch: feature/add-button
-> Squashing last 2 commits
-> Commits to squash (2):
   1. def5678 fix: button style
   2. ghi9012 refactor: clean up

-> Enter commit title: fix: improve button styling

-> Squashing...
-> Squashed 2 commits

-> Final commit message:
   +----------------------------------------
   | fix: improve button styling
   |
   | * fix: button style
   | * refactor: clean up
   +----------------------------------------

-> Run 'git push --force-with-lease' to update remote
```

**Protected branch error:**

```text
/stylish-git:squash

-> Error: Cannot squash on protected branch 'main'
-> Switch to a feature branch first
```

**No commits error:**

```text
/stylish-git:squash

-> No commits to squash
-> Current branch has no commits ahead of main
```
