# Stylish Code

🌐 [한국어](./README.ko.md) | **English**

Stylish productivity plugins for Claude Code.

## Installation

Add this marketplace to Claude Code:

```shell
/plugin marketplace add stylelist94/claude-plugins
```

Then install individual plugins:

```shell
/plugin install stylish-git@stylish-code
/plugin install stylish-docs@stylish-code
/plugin install stylish-frontend@stylish-code
/plugin install stylish-review@stylish-code
/plugin install stylish-packages@stylish-code
```

## Available Plugins

### stylish-git

Git workflow tools for streamlined version control operations.

**Skills:**

- `/stylish-git:commit` - Intelligent commit message generator
- `/stylish-git:squash` - Squash commits like GitHub PR merge
- `/stylish-git:rebase` - Rebase with intelligent conflict resolution
- `/stylish-git:cleanup-branch` - Branch cleanup and management
- `/stylish-git:create-worktree` - Create isolated worktree for feature work

---

### stylish-docs

Documentation generator and reviewer for README and React TSDoc.

**Skills:**

- `/stylish-docs:readme` - README file generator
- `/stylish-docs:react-tsdoc` - React component TSDoc generator

**Agents:**

- `doc-reviewer` - Review documentation for quality, completeness, and code-docs consistency

**Output Styles:**

- `doc-review-report` - Structured format for documentation review results

---

### stylish-frontend

Frontend component development workflow tools.

**Skills:**

- `/stylish-frontend:figma-to-code` - Convert Figma designs to code (requires Figma MCP)
- `/stylish-frontend:vitest-browser` - Vitest browser test generation
- `/stylish-frontend:component-workflow` - Component development workflow

**Agents:**

- `component-reviewer` - Review components for pattern consistency, accessibility, and best practices

**Output Styles:**

- `component-review-report` - Structured format for component review results

> **Note:** `/stylish-frontend:figma-to-code` requires [Figma MCP Server](https://github.com/figma/mcp-server-guide).

---

### stylish-review

Interactive code review workflow that runs the full review pipeline and walks you through each finding one-by-one.

**Skills:**

- `/stylish-review:code-review` - Interactive code review walkthrough (PR or local diff, per-finding apply/modify/defer/dismiss)

---

### stylish-packages

Smart bulk dependency updates that protect frameworks and align `@types/node` with the latest Node major actually installed on the machine.

**Skills:**

- `/stylish-packages:update` - Bulk-update deps across npm/pnpm/yarn/bun. Auto-bumps safe patches/minors, asks per-package for majors, holds back frameworks (TypeScript, Next.js, React, etc.) and self-upgrading packages (Storybook, Prisma, shadcn, etc.) with the right CLI hint.

## License

MIT
