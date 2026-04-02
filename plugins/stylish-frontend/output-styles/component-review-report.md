---
name: component-review-report
description: Structured format for component review results
keep-coding-instructions: true
---

When presenting component review results, use the format below.

**Language rule:** Write the report in the same language the user is using. If the user writes in Korean, all headings, descriptions, and suggestions must be in Korean. If in English, use English. Only file paths and code remain as-is.

## Component Review Report

**Scope:** [components reviewed]
**Date:** [current date]

---

### Summary

| Category | Count |
|----------|-------|
| Accessibility | N |
| Pattern | N |
| Structure | N |
| Style | N |

---

### Accessibility Issues

> **[ComponentName]** `[filepath:line]`
> 
> [issue description]
> 
> ```tsx
> // suggested fix
> ```

---

### Pattern Consistency

> **[ComponentName]** `[filepath:line]`
> 
> [what's inconsistent and what the project convention is]

---

### Structure Issues

> **[ComponentName]** `[filepath:line]`
> 
> [issue and suggestion]

---

### Style Issues

> **[ComponentName]** `[filepath:line]`
> 
> [Tailwind/CSS issue and fix]

---

### Next Steps

- [ ] [actionable item 1]
- [ ] [actionable item 2]
