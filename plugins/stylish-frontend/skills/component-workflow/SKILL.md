---
description: Full component development workflow - Figma design to tested React component
---

# Component Development Workflow

Orchestrate the complete component development process: from Figma design to production-ready, tested React component.

## Workflow Steps

### Step 1: Design to Code

Execute the `/stylish-figma-to-code` skill to:

- Extract design from Figma
- Generate JSX/Astro component
- Apply Tailwind CSS styles
- Validate accessibility

### Step 2: User Confirmation

After component generation:

- Show the generated component code
- Ask user to review and confirm
- Allow modifications if needed

### Step 3: Test Generation

Once component is confirmed, ask:
> "Component generated successfully. Would you like to generate tests with `/stylish-vitest-browser`?"

If user agrees, execute `/stylish-vitest-browser` to:

- Analyze component structure
- Classify as Simple or Complex
- Generate Vitest Browser Mode tests
- Include accessibility checks

## Usage

```bash
# Start the full workflow
/stylish-component-workflow [figma-url-or-node-id]

# With options
/stylish-component-workflow [figma-url] --react
/stylish-component-workflow [figma-url] --astro
```

## Workflow Diagram

```text
┌─────────────────┐
│  Figma Design   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ /stylish-figma  │
│   -to-code      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  User Review    │
│  & Confirmation │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Generate tests? │──No──▶ Done
└────────┬────────┘
         │ Yes
         ▼
┌─────────────────┐
│ /stylish-vitest │
│    -browser     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Ready to Ship!  │
└─────────────────┘
```

## Requirements

- **Figma MCP server** must be configured for design extraction
- **Vitest Browser Mode** dependencies for test generation:
  - `@vitest/browser*`
  - `vitest-browser-react`

## Output

At the end of the workflow, you will have:

1. **Component file** (.tsx or .astro) with Tailwind styles
2. **Test file** (.test.tsx) with comprehensive browser tests

## Tips

- Review the generated component before proceeding to tests
- Request modifications if the component needs adjustments
- Tests are generated based on the final component structure
