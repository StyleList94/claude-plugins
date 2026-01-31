---
description: Generate StyleList94-style README.md based on project type
---

Generate clean, practical README.md files tailored to project type.

## Project Type Detection

Detect project type by analyzing:

| Type | Detection Criteria |
| ---- | ------------------ |
| Library/Package | `package.json` has `main`, `exports`, or `types` field |
| CLI Tool | `package.json` has `bin` field |
| Plugin Marketplace | `.claude-plugin/marketplace.json` exists |
| Personal Project | None of the above |

> Note: Profile README repositories (username/username) are special-purpose and excluded.

## Section Structure by Type

### Library/Package

```markdown
# Project Name

One-line description

## Getting Started

### Installation

pnpm add package-name

# or npm
npm install package-name

# or yarn
yarn add package-name

### Usage

Basic usage code block

## Features

- Core feature list

## API Reference (optional)

Key API documentation
```

### CLI Tool

```markdown
# Project Name

One-line description

## Getting Started

### Installation

pnpm add -g package-name

## Options

CLI options table or list

## Example

Usage examples
```

### Plugin Marketplace

```markdown
# Project Name

One-line description

## Installation

How to register with marketplace

## Available Plugins

Plugin list

## Project Structure

Directory structure explanation
```

### Personal Project

```markdown
# Project Name

Project description

## Getting Started

Simple run commands
```

## Style Guidelines

### Package Manager

- **pnpm first** as primary
- Provide npm/yarn alternatives:

```bash
pnpm add package-name

# or npm
npm install package-name

# or yarn
yarn add package-name
```

### Code Blocks

- Always specify language: `bash`, `typescript`, `tsx`, etc.
- One command per block for easy copying

### Formatting

- Single blank line between sections
- No unnecessary badges or decorations
- Practical, no-frills style

## Behavior

1. **New README**: Detect project type → Generate appropriate section structure
2. **Update README**: Preserve existing style while adding missing sections
