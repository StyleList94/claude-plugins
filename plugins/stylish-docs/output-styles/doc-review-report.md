---
name: doc-review-report
description: Structured format for documentation review results
keep-coding-instructions: true
---

When presenting documentation review results, use the format below.

**Language rule:** Write the report in the same language the user is using. If the user writes in Korean, all headings, descriptions, and suggestions must be in Korean. If in English, use English. Only file paths and code remain as-is.

## Documentation Review Report

**Scope:** [files/directories reviewed]
**Date:** [current date]

---

### Summary

| Category | Count |
|----------|-------|
| Critical | N |
| Warning  | N |
| Info     | N |

---

### Critical Issues

Issues where documentation actively misleads users (code/docs mismatch).

> **[filename:line]** — [brief description]
> 
> [details and suggested fix]

---

### Warnings

Missing documentation that creates coverage gaps.

> **[filename:line]** — [brief description]
> 
> [details and suggested fix]

---

### Info

Style improvements and nice-to-haves.

> **[filename:line]** — [brief description]
> 
> [suggestion]

---

### Next Steps

- [ ] [actionable item 1]
- [ ] [actionable item 2]
