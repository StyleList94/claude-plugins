---
description: Rebase branch with intelligent conflict resolution and force push
---

Rebase current branch onto base branch with smart conflict resolution.

## Use Case

- PR has conflicts with main/master
- Need to update feature branch with latest changes
- Clean up branch history before merge

## Process

1. **Safety check**: Prevent running on protected branches (main, master, develop)
2. **Detect base branch**: Usually `main` or `master`
3. **Fetch and rebase**:
   ```bash
   git fetch origin <base>
   git rebase origin/<base>
   ```
4. **Handle conflicts automatically**

## Conflict Resolution Strategy

### Lockfile Conflicts (Auto-resolve)

Lockfile conflicts are resolved by reinstalling:

1. Accept incoming version: `git checkout --theirs <lockfile>`
2. Reinstall based on package manager:
   - `package-lock.json` → `npm install`
   - `yarn.lock` → `yarn install`
   - `pnpm-lock.yaml` → `pnpm install`
3. Stage and continue: `git add <lockfile> && git rebase --continue`

### Code Conflicts (Smart merge)

**Auto-resolve cases:**
- Both sides add imports → keep all imports
- Both sides add functions/variables → keep both
- Duplicate lines → remove duplicates

**Ask user cases:**
- Same line modified differently
- Logic conflicts
- Ambiguous merges

### Resolution Flow

```
Conflict detected
├─ Lockfile only → auto reinstall → continue
├─ Code (simple) → Claude merges both sides → continue
├─ Code (complex) → show conflict, ask user
└─ Mixed → resolve lockfile first, then code
```

## Safety Features

- **Protected branches**: Never rebase main/master/develop
- **force-with-lease**: Safer than `--force`
- **Smart conflict detection**: Categorize before attempting resolution

## Execution Steps

1. Check current branch is not protected
2. Run `git fetch origin` to get latest
3. Detect base branch (main or master)
4. Run `git rebase origin/<base>`
5. If conflicts:
   - Identify conflict type (lockfile vs code)
   - Apply appropriate resolution strategy
   - Continue rebase with `git rebase --continue`
   - Repeat until complete
6. Push with `git push --force-with-lease`

## Examples

**Clean rebase:**
```
/stylish-rebase
→ Current branch: feature/add-button
→ Fetching origin/main...
→ Rebasing onto origin/main...
→ No conflicts ✅
→ Pushing with --force-with-lease...
→ Done ✅
```

**Lockfile conflict:**
```
/stylish-rebase
→ Rebasing onto origin/main...
→ Conflict: package-lock.json (lockfile)
→ Auto-resolving: npm install...
→ Continuing rebase...
→ Done ✅
```

**Code conflict (auto-resolved):**
```
/stylish-rebase
→ Conflict: src/utils.ts
→ Analyzing... both sides add different imports
→ Merging: keeping all imports
→ Continuing rebase...
→ Done ✅
```

**Code conflict (needs input):**
```
/stylish-rebase
→ Conflict: src/api.ts
→ Same function modified differently on both sides
→ Showing both versions...
→ Which version to keep? (ours/theirs/manual)
```

**Protected branch error:**
```
/stylish-rebase
→ Error: Cannot rebase on protected branch 'main'
→ Switch to a feature branch first
```
