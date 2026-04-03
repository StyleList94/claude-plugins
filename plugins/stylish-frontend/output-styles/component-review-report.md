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
| Naming & Types | N |
| State Matrix | N |
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

### Pattern Issues

ref handling, controlled/uncontrolled, compound components, props forwarding, API consistency.

> **[ComponentName]** `[filepath:line]`
> 
> [what's inconsistent and what the project convention is]

---

### Naming & Types Issues

> **[ComponentName]** `[filepath:line]`
> 
> [naming or type discipline issue]

---

### State Matrix Issues

Uncovered or broken state combinations (variant × hover × disabled × checked, etc.).

> **[ComponentName]** `[filepath:line]`
> 
> [which state combination is missing or broken]

---

### Structure Issues

> **[ComponentName]** `[filepath:line]`
> 
> [issue and suggestion]

---

### Style Issues

> **[ComponentName]** `[filepath:line]`
> 
> [CSS/styling issue and fix]

---

### Next Steps

- [ ] [actionable item 1]
- [ ] [actionable item 2]
