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
```

## Available Plugins

### stylish-git

Git workflow tools for streamlined version control operations.

**Skills:**

- `/stylish-git:commit` - Intelligent commit message generator
- `/stylish-git:rebase` - Interactive rebase assistance
- `/stylish-git:cleanup-branch` - Branch cleanup and management

---

### stylish-docs

Documentation generator for README and React TSDoc.

**Skills:**

- `/stylish-docs:readme` - README file generator
- `/stylish-docs:react-tsdoc` - React component TSDoc generator

---

### stylish-frontend

Frontend component development workflow tools.

**Skills:**

- `/stylish-frontend:figma-to-code` - Convert Figma designs to code (requires Figma MCP)
- `/stylish-frontend:vitest-browser` - Vitest browser test generation
- `/stylish-frontend:component-workflow` - Component development workflow

> **Note:** `/stylish-figma-to-code` requires [Figma MCP Server](https://github.com/figma/mcp-server-guide).

## License

MIT
