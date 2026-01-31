---
description: Clean up merged and stale branches from local and remote
---

Clean up branches that have been merged or are no longer needed.

## Use Case

- Remove merged feature branches after PR merge
- Clean up stale branches that haven't been used
- Keep repository tidy with minimal branch clutter

## Process

1. **Fetch latest**: `git fetch --prune origin`
2. **Find merged branches**: `git branch --merged main`
3. **Identify targets**: Exclude protected branches (main, master, develop)
4. **Show preview**: List branches to be deleted
5. **Confirm with user**: Ask before deletion
6. **Delete**: Remove from local and optionally remote

## Branch Detection

### Merged Branches

```bash
# Local branches merged into main
git branch --merged main

# Remote branches merged into main
git branch -r --merged origin/main
```

### Stale Branches (Optional)

Branches with no commits in N days:
```bash
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:relative)' refs/heads/
```

## Safety Features

- **Protected branches**: Never delete main, master, develop
- **Current branch**: Never delete the branch you're on
- **Preview first**: Always show what will be deleted before doing it
- **User confirmation**: Require explicit yes before deletion
- **Remote caution**: Extra confirmation for remote branch deletion

## Execution Steps

1. Run `git fetch --prune origin` to sync
2. Detect default branch (main or master)
3. Run `git branch --merged <default>` for local
4. Run `git branch -r --merged origin/<default>` for remote
5. Filter out protected branches
6. Show preview to user
7. Ask for confirmation
8. Delete confirmed branches:
   - Local: `git branch -d <branch>`
   - Remote: `git push origin --delete <branch>`

## Examples

**Basic cleanup:**
```
/stylish-cleanup-branch
→ Fetching and analyzing branches...
→ Found 3 merged branches:

  Local (merged into main):
  - feature/add-button
  - feature/fix-header
  - bugfix/typo

  Protected (skipped):
  - main
  - develop

→ Delete these 3 local branches? (y/n)
→ Deleted 3 branches ✅
```

**With remote cleanup:**
```
/stylish-cleanup-branch --remote
→ Found 5 merged branches:

  Local:
  - feature/add-button
  - feature/fix-header

  Remote:
  - origin/feature/old-feature
  - origin/feature/completed-work
  - origin/bugfix/fixed

→ Delete 2 local + 3 remote branches? (y/n)
→ Deleted 5 branches ✅
```

**Nothing to clean:**
```
/stylish-cleanup-branch
→ Fetching and analyzing branches...
→ No merged branches found ✅
→ Repository is clean
```

**Dry run:**
```
/stylish-cleanup-branch --dry-run
→ Would delete (dry run):
  - feature/add-button
  - feature/fix-header
→ Run without --dry-run to delete
```
