# Vitest Browser Mode API Reference

> **Key Principle**: Minimize `.element()` direct access, use Testing Library style queries + DOM matchers with auto-retry assertions.

## Imports

Check tsconfig for `vitest/globals` in `compilerOptions.types` to determine import strategy.

**With Vitest Globals (tsconfig has `"types": ["vitest/globals"]`):**

```tsx
import { page, userEvent } from 'vitest/browser'
import { render } from 'vitest-browser-react'
// describe, it, expect, vi, beforeEach are globally available
```

**Without Vitest Globals:**

```tsx
import { page, userEvent } from 'vitest/browser'
import { render } from 'vitest-browser-react'
import { expect, vi, describe, it, beforeEach } from 'vitest'
```

## Locators (Testing Library Style)

Use locators in priority order for maintainable tests:

| Priority | Method | Purpose |
|----------|--------|---------|
| 1 | `getByRole` | ARIA role based (recommended) |
| 2 | `getByLabelText` | Label associated element |
| 3 | `getByPlaceholder` | placeholder attribute |
| 4 | `getByText` | Text content |
| 5 | `getByTestId` | data-testid (last resort) |

### getByRole Examples

```tsx
// Basic role queries
page.getByRole('button')
page.getByRole('textbox')
page.getByRole('checkbox')
page.getByRole('dialog')
page.getByRole('listbox')
page.getByRole('option')
page.getByRole('tab')
page.getByRole('tabpanel')

// With name (accessible name)
page.getByRole('button', { name: 'Submit' })
page.getByRole('button', { name: /submit/i })  // RegExp

// With state
page.getByRole('checkbox', { checked: true })
page.getByRole('textbox', { disabled: true })
page.getByRole('tab', { selected: true })
page.getByRole('option', { selected: true })

// With level (headings)
page.getByRole('heading', { level: 1 })  // <h1>
page.getByRole('heading', { level: 2 })  // <h2>
```

### Locator Chaining

```tsx
// Get first/nth element
page.getByRole('listitem').first()
page.getByRole('listitem').nth(2)
page.getByRole('listitem').last()

// Filter by content
page.getByRole('article').filter({ has: page.getByText('Vitest') })

// Combine locators (OR)
page.getByRole('button').or(page.getByRole('link')).first()

// Get all matching
page.getByRole('listitem').all()
```

### Other Locator Methods

```tsx
// By label
page.getByLabelText('Email')
page.getByLabelText(/email/i)

// By placeholder
page.getByPlaceholder('Enter your email')

// By text content
page.getByText('Welcome')
page.getByText(/welcome/i)

// By test ID (last resort)
page.getByTestId('submit-button')
```

## Assertions

Use `await expect.element()` for auto-retry assertions:

### Visibility & Presence

```tsx
await expect.element(page.getByRole('button')).toBeVisible()
await expect.element(page.getByRole('dialog')).toBeInTheDocument()
await expect.element(page.getByText('Loading')).not.toBeInTheDocument()
```

### Text Content

```tsx
await expect.element(page.getByRole('heading')).toHaveTextContent('Welcome')
await expect.element(page.getByRole('alert')).toHaveTextContent(/error/i)
```

### Attributes

```tsx
await expect.element(page.getByRole('link')).toHaveAttribute('href', '/home')
await expect.element(page.getByRole('img')).toHaveAttribute('alt')
await expect.element(page.getByRole('button')).toHaveAttribute('type', 'submit')
```

### Form State

```tsx
await expect.element(page.getByRole('textbox')).toHaveValue('hello')
await expect.element(page.getByRole('checkbox')).toBeChecked()
await expect.element(page.getByRole('button')).toBeDisabled()
await expect.element(page.getByRole('textbox')).toBeEnabled()
await expect.element(page.getByRole('textbox')).toBeRequired()
```

### Focus

```tsx
await expect.element(page.getByRole('textbox')).toHaveFocus()
```

### CSS Classes

```tsx
await expect.element(page.getByRole('button')).toHaveClass('btn-primary')
await expect.element(page.getByRole('button')).toHaveClass('btn', 'btn-lg')
```

### Complete Matchers Reference

| Matcher | Purpose |
|---------|---------|
| `toBeVisible()` | Element is visible |
| `toBeInTheDocument()` | Element exists in DOM |
| `toHaveTextContent(text)` | Contains text |
| `toHaveAttribute(attr, value?)` | Has attribute |
| `toHaveValue(value)` | Form input value |
| `toHaveClass(...classes)` | CSS classes |
| `toHaveFocus()` | Has focus |
| `toBeChecked()` | Checkbox/radio checked |
| `toBeDisabled()` | Is disabled |
| `toBeEnabled()` | Is enabled |
| `toBeRequired()` | Required field |
| `toContainElement(element)` | Contains child element |

## User Interactions

### Locator Methods (Recommended)

```tsx
// Click
await page.getByRole('button').click()
await page.getByRole('button').dblclick()

// Type in input
await page.getByRole('textbox').fill('hello@example.com')
await page.getByRole('textbox').clear()

// Focus
await page.getByRole('textbox').focus()

// Hover (limited support, prefer userEvent)
await page.getByRole('button').hover()
```

### userEvent (Complex Interactions)

```tsx
// Keyboard
await userEvent.keyboard('{Enter}')
await userEvent.keyboard('{Escape}')
await userEvent.keyboard('{Tab}')
await userEvent.keyboard('{ArrowDown}')
await userEvent.keyboard('{ArrowUp}')
await userEvent.keyboard('Hello World')  // Type text

// Tab navigation
await userEvent.tab()
await userEvent.tab({ shift: true })  // Shift+Tab

// Hover
await userEvent.hover(page.getByText('Tooltip trigger'))
await userEvent.unhover(page.getByText('Tooltip trigger'))

// Click (alternative)
await userEvent.click(page.getByRole('button'))
await userEvent.dblClick(page.getByRole('button'))
```

## Rendering

### Basic Render

```tsx
await render(<MyComponent />)

// Query via page after render
await expect.element(page.getByRole('button')).toBeVisible()
await page.getByRole('textbox').fill('test')
```

### With Destructuring (When Needed)

```tsx
// container: root element
const { container } = await render(<MyComponent />)

// rerender: update props
const { rerender } = await render(<MyComponent value="a" />)
await rerender(<MyComponent value="b" />)

// unmount: cleanup
const { unmount } = await render(<MyComponent />)
unmount()
```

### With Wrapper

```tsx
// CenteredWrapper for visual stability in browser tests
const CenteredWrapper = ({ children }: { children: React.ReactNode }) => (
  <div style={{
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: '100vh',
    padding: '20px'
  }}>
    {children}
  </div>
)

await render(
  <CenteredWrapper>
    <Dialog open>...</Dialog>
  </CenteredWrapper>
)
```

## Mocking

### Functions

```tsx
const handleClick = vi.fn()
await render(<Button onClick={handleClick}>Click me</Button>)
await page.getByRole('button').click()
expect(handleClick).toHaveBeenCalled()
expect(handleClick).toHaveBeenCalledTimes(1)
expect(handleClick).toHaveBeenCalledWith(expect.any(Object))  // event
```

### Callbacks with Arguments

```tsx
const onChange = vi.fn()
await render(<Input onChange={onChange} />)
await page.getByRole('textbox').fill('hello')
expect(onChange).toHaveBeenCalledWith('hello')
```

## Anti-Patterns

### ❌ Avoid: Direct .element() Access

```tsx
// ❌ No auto-retry, can cause flaky tests
expect(page.getByRole('button').element()).toBeInTheDocument()

// ✅ Correct: Use await expect.element()
await expect.element(page.getByRole('button')).toBeInTheDocument()
```

### ❌ Avoid: Manual Waits

```tsx
// ❌ Avoid arbitrary waits
await new Promise(r => setTimeout(r, 1000))

// ✅ Use auto-retry assertions
await expect.element(page.getByText('Loaded')).toBeVisible()
```

### ❌ Avoid: Implementation Details

```tsx
// ❌ Testing implementation
expect(container.querySelector('.btn-class')).toBeTruthy()

// ✅ Test behavior
await expect.element(page.getByRole('button')).toBeVisible()
```

## Async Patterns

### Waiting for Elements

```tsx
// Auto-retry until element appears (default timeout)
await expect.element(page.getByRole('alert')).toBeVisible()

// With custom timeout
await expect.element(page.getByRole('dialog')).toBeVisible({ timeout: 5000 })
```

### Waiting for State Changes

```tsx
await page.getByRole('button', { name: 'Submit' }).click()

// Wait for loading to disappear
await expect.element(page.getByText('Loading')).not.toBeInTheDocument()

// Wait for success message
await expect.element(page.getByRole('alert')).toHaveTextContent('Success')
```
