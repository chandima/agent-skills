---
name: basecoat
description: Basecoat UI component patterns with Tailwind CSS classes for shadcn/ui-like components without React. Use when building UI with class-based components.
---

# Basecoat UI

Tailwind-based component library providing shadcn/ui-like components without React. Pair with Alpine.js for interactivity.

## Installation

```bash
npx basecoat@latest init
npx basecoat@latest add button card dialog
```

## Buttons

```html
<!-- Variants -->
<button class="btn btn-primary">Primary</button>
<button class="btn btn-secondary">Secondary</button>
<button class="btn btn-outline">Outline</button>
<button class="btn btn-ghost">Ghost</button>
<button class="btn btn-destructive">Destructive</button>

<!-- Sizes -->
<button class="btn btn-primary btn-sm">Small</button>
<button class="btn btn-primary">Default</button>
<button class="btn btn-primary btn-lg">Large</button>

<!-- With icon -->
<button class="btn btn-primary">
  <svg class="btn-icon">...</svg>
  With Icon
</button>

<!-- Icon only -->
<button class="btn btn-ghost btn-icon-only" aria-label="Settings">
  <svg>...</svg>
</button>

<!-- Button group -->
<div class="btn-group">
  <button class="btn btn-outline">Left</button>
  <button class="btn btn-outline">Center</button>
  <button class="btn btn-outline">Right</button>
</div>
```

## Forms

```html
<!-- Field with label -->
<div class="field">
  <label for="email" class="label">Email</label>
  <input type="email" id="email" class="input" placeholder="you@example.com">
  <p class="field-description">We'll never share your email.</p>
</div>

<!-- With error -->
<div class="field">
  <label class="label">Password</label>
  <input type="password" class="input input-error">
  <p class="field-error">Password must be at least 8 characters.</p>
</div>

<!-- Select -->
<select class="select">
  <option value="">Choose...</option>
  <option value="1">Option 1</option>
</select>

<!-- Checkbox -->
<label class="checkbox">
  <input type="checkbox" class="checkbox-input">
  <span class="checkbox-label">Accept terms</span>
</label>

<!-- Switch -->
<label class="switch">
  <input type="checkbox" class="switch-input">
  <span class="switch-slider"></span>
  <span class="switch-label">Enable</span>
</label>

<!-- Textarea -->
<textarea class="textarea" rows="4" placeholder="Message"></textarea>
```

## Cards

```html
<div class="card">
  <div class="card-header">
    <h3 class="card-title">Title</h3>
    <p class="card-description">Description</p>
  </div>
  <div class="card-content">
    Main content
  </div>
  <div class="card-footer">
    <button class="btn btn-primary">Action</button>
  </div>
</div>
```

## Dialog (with Alpine.js)

```html
<div x-data="{ open: false }">
  <button @click="open = true" class="btn btn-primary">Open</button>
  
  <div x-show="open" x-cloak class="dialog-overlay" @click.self="open = false">
    <div class="dialog" x-trap.inert="open">
      <div class="dialog-header">
        <h2 class="dialog-title">Title</h2>
        <button @click="open = false" class="btn btn-ghost btn-icon-only">✕</button>
      </div>
      <div class="dialog-content">
        Content here
      </div>
      <div class="dialog-footer">
        <button @click="open = false" class="btn btn-outline">Cancel</button>
        <button class="btn btn-primary">Confirm</button>
      </div>
    </div>
  </div>
</div>
```

## Dropdown

```html
<div x-data="{ open: false }" class="dropdown">
  <button @click="open = !open" class="btn btn-outline">
    Options
    <svg class="dropdown-chevron">...</svg>
  </button>
  
  <div x-show="open" @click.outside="open = false" x-transition class="dropdown-menu">
    <button class="dropdown-item">Edit</button>
    <button class="dropdown-item">Duplicate</button>
    <div class="dropdown-separator"></div>
    <button class="dropdown-item dropdown-item-destructive">Delete</button>
  </div>
</div>
```

## Tabs

```html
<div x-data="{ tab: 'account' }">
  <div class="tabs">
    <button @click="tab = 'account'" :class="tab === 'account' && 'tab-active'" class="tab">
      Account
    </button>
    <button @click="tab = 'settings'" :class="tab === 'settings' && 'tab-active'" class="tab">
      Settings
    </button>
  </div>
  
  <div x-show="tab === 'account'" class="tab-content">Account settings</div>
  <div x-show="tab === 'settings'" class="tab-content">Settings content</div>
</div>
```

## Alerts

```html
<div class="alert">
  <svg class="alert-icon">...</svg>
  <div class="alert-content">
    <h4 class="alert-title">Heads up!</h4>
    <p class="alert-description">Information message.</p>
  </div>
</div>

<div class="alert alert-success">...</div>
<div class="alert alert-warning">...</div>
<div class="alert alert-error">...</div>
```

## Badges

```html
<span class="badge">Default</span>
<span class="badge badge-primary">Primary</span>
<span class="badge badge-success">Success</span>
<span class="badge badge-warning">Warning</span>
<span class="badge badge-error">Error</span>
```

## Tables

```html
<div class="table-container">
  <table class="table">
    <thead>
      <tr>
        <th>Name</th>
        <th>Status</th>
        <th class="text-right">Actions</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>John Doe</td>
        <td><span class="badge badge-success">Active</span></td>
        <td class="text-right">
          <button class="btn btn-ghost btn-sm">Edit</button>
        </td>
      </tr>
    </tbody>
  </table>
</div>
```

## Loading States

```html
<!-- Spinner -->
<div class="spinner"></div>
<div class="spinner spinner-sm"></div>

<!-- Progress -->
<div class="progress">
  <div class="progress-bar" style="width: 60%"></div>
</div>

<!-- Skeleton -->
<div class="skeleton h-4 w-full"></div>
<div class="skeleton h-4 w-3/4"></div>
```

## Avatar

```html
<div class="avatar">
  <img src="/user.jpg" alt="User">
</div>
<div class="avatar avatar-sm">
  <span class="avatar-fallback">JD</span>
</div>
```

## Accessibility Notes

- Always add `aria-label` to icon-only buttons
- Use `x-trap.inert` for modal focus trapping
- Include `x-cloak` to prevent flash of unstyled content
- Add `role="alertdialog"` for destructive confirmations

## References

See `.apm/instructions/astro.instructions.md` for complete Basecoat patterns including:
- Accordion, Breadcrumb, Pagination
- Command Palette, Combobox
- Toast notifications
- Theme switching
