# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin marketplace - a repository that distributes plugins (skills, commands, agents, hooks) to Claude Code users via the `/plugin marketplace add` command.

## Key Files

- `.claude-plugin/marketplace.json` - Main marketplace catalog listing all plugins
- `plugins/*/` - Individual plugin directories
- `plugins/*/.claude-plugin/plugin.json` - Plugin manifests
- `plugins/*/skills/*/SKILL.md` - Skill definitions (markdown with YAML frontmatter)

## Commands

**Validate marketplace:**
```bash
claude plugin validate .
```

**Test locally:**
```shell
/plugin marketplace add ./
/plugin install <plugin-name>@stylish-code
```

## Plugin Structure

Each plugin follows this structure:
```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json       # name, description, version, author, license
└── skills/
    └── <skill-name>/
        └── SKILL.md      # YAML frontmatter + markdown instructions
```

## SKILL.md Format

```markdown
---
description: Brief description shown in /help
disable-model-invocation: true  # optional: prevents auto-invocation
---

Instructions for Claude when this skill is invoked.
```

## Adding Plugins

1. Create plugin directory structure under `plugins/`
2. Add `plugin.json` manifest
3. Add skill/command definitions
4. Register in `.claude-plugin/marketplace.json`
5. Validate with `claude plugin validate .`

## Naming Conventions

- Plugin names: kebab-case (e.g., `review-plugin`)
- Skill names: kebab-case, matching the slash command (e.g., `review` for `/review`)
- Marketplace name: `stylish-code` (users install via `@stylish-code` suffix)

## Documentation

- Update both `README.md` (English) and `README.ko.md` (Korean) when adding/modifying plugins
