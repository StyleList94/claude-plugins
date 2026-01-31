---
description: Generate intelligent commit messages following StyleList94's commit convention
---

Analyze staged changes and generate a commit message following the project's commit convention.

## Commit Format

```
<type>(<scope>): <subject>

<body>
```

## Types (빈도순)

| Type | Usage | Description |
|------|-------|-------------|
| **feat** | 32% | New feature or update |
| **chore** | 30% | Dependencies, releases, config |
| **refactor** | 12% | Code reorganization |
| **ci** | 8% | CI/CD workflow changes |
| **fix** | 5% | Bug fixes |
| **docs** | 5% | Documentation updates |
| **style** | 1% | Code formatting (rare) |
| **perf** | rare | Performance improvements |
| **test** | rare | Adding or fixing tests |

## Style Rules

1. **Language**: English only
2. **Case**: All lowercase (type, scope, subject)
3. **Emoji**: Do not use
4. **Length**: Keep subject under 50 characters
5. **Mood**: Imperative ("add" not "added")
6. **Punctuation**: No period at end

## Scope Usage (40% of commits)

Use scope selectively:
- `(deps)`: Dependency updates → `chore(deps): bump next.js`
- `(release)`: Version releases → `chore(release): v1.2.3`
- `(security)`: Security patches → `fix(security): patch vulnerability`
- **Most commits**: Skip scope → `feat: add button component`

## Body Format (for complex changes)

Use bullet points with type prefixes:
```
feat: migrate to vanilla-extract

* feat: add vanilla-extract/css
* refactor: migrate layout components
* refactor: migrate button component
* chore: update vite plugin
```

## Breaking Changes

- Add `!` after type/scope: `feat!: remove deprecated API`

## Process

1. Run `git diff --staged` to analyze changes
2. Determine the primary change type
3. Decide if scope is needed (deps/release/security)
4. Write concise lowercase subject
5. Add bullet-point body for multiple changes
6. Present ready-to-execute commit command

## Examples

**Simple feature:**
```
feat: add loading state to button
```

**Dependency update:**
```
chore(deps): bump react to 19.0.0
```

**Complex change with body:**
```
feat: implement dark mode

* feat: add theme context provider
* refactor: update color tokens
* docs: update readme
```

**Release:**
```
chore(release): v2.1.0
```
