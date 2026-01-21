---
applyTo: "**/*.astro"
description: "Astro component patterns, Tailwind CSS usage, and accessibility standards"
---

# Astro Development Standards

## Component Structure

### File Organization
```astro
---
// 1. Imports (external, then internal)
import Layout from '@/layouts/Layout.astro';
import { Card } from '@/components/Card.astro';

// 2. Props interface
interface Props {
  title: string;
  description?: string;
}

// 3. Props destructuring
const { title, description = 'Default description' } = Astro.props;

// 4. Data fetching and logic
const posts = await getPosts();
---

<!-- 5. Template -->
<Layout title={title}>
  <main>
    <h1>{title}</h1>
  </main>
</Layout>

<!-- 6. Scoped styles (if needed) -->
<style>
  /* Component-specific styles */
</style>

<!-- 7. Client-side scripts (if needed) -->
<script>
  // Minimal client JS
</script>
```

### Props Definition
- Always define a `Props` interface
- Use descriptive prop names
- Provide sensible defaults for optional props

```astro
---
interface Props {
  /** Page title shown in browser tab */
  title: string;
  /** Meta description for SEO */
  description?: string;
  /** Whether to include in sitemap */
  indexable?: boolean;
}

const { 
  title, 
  description = 'Welcome to our site',
  indexable = true,
} = Astro.props;
---
```

## Tailwind CSS Usage

### Class Organization
Order Tailwind classes consistently:
1. Layout (display, position, grid/flex)
2. Sizing (width, height, padding, margin)
3. Typography (font, text, leading)
4. Visual (background, border, shadow)
5. Interactive (hover, focus, transition)

```astro
<!-- Organized classes -->
<div class="flex items-center justify-between p-4 text-lg font-medium bg-white border rounded-lg hover:shadow-md transition-shadow">
```

### Responsive Design
- Mobile-first approach
- Use responsive prefixes consistently: `sm:`, `md:`, `lg:`, `xl:`
- Group responsive variants logically

```astro
<div class="
  grid grid-cols-1 gap-4
  sm:grid-cols-2
  lg:grid-cols-3
  xl:grid-cols-4
">
```

### Custom Classes
- Use `@apply` sparingly, only for frequently repeated patterns
- Prefer component extraction over utility abstraction

```css
/* Only for very common patterns */
.btn-primary {
  @apply px-4 py-2 font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700;
}
```

## Accessibility

### Semantic HTML
- Use correct heading hierarchy (h1 > h2 > h3)
- Use semantic elements: `<nav>`, `<main>`, `<article>`, `<section>`, `<aside>`
- Use `<button>` for actions, `<a>` for navigation

### ARIA Labels
- Provide labels for interactive elements without visible text
- Use `aria-label`, `aria-labelledby`, or `aria-describedby` appropriately

```astro
<!-- Icon-only button needs label -->
<button aria-label="Close modal" class="...">
  <CloseIcon />
</button>

<!-- Link with additional context -->
<a href="/post/123" aria-describedby="post-123-title">
  Read more
</a>
```

### Keyboard Navigation
- Ensure all interactive elements are focusable
- Provide visible focus indicators
- Support expected keyboard patterns (Enter, Escape, arrows)

```astro
<button 
  class="focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
>
  Click me
</button>
```

### Color and Contrast
- Maintain WCAG AA contrast ratio (4.5:1 for normal text)
- Never rely on color alone to convey meaning
- Test with color blindness simulators

## Image Optimization

### Use Astro Image
- Always use `<Image>` from `astro:assets` for local images
- Provide alt text for all images
- Specify width and height to prevent layout shift

```astro
---
import { Image } from 'astro:assets';
import heroImage from '@/assets/hero.jpg';
---

<Image 
  src={heroImage}
  alt="Team collaborating in modern office"
  width={1200}
  height={630}
  loading="eager" <!-- For above-the-fold images -->
/>
```

### External Images
- Configure allowed domains in astro.config
- Always provide dimensions

```astro
<Image 
  src="https://example.com/image.jpg"
  alt="Description"
  width={800}
  height={600}
  inferSize <!-- When dimensions unknown -->
/>
```

## Client-Side JavaScript

### Minimize Client JS
- Use Astro's zero-JS by default
- Add interactivity only where needed
- Prefer CSS-only solutions when possible

### Client Directives
Choose the appropriate hydration strategy:

```astro
<!-- Hydrate immediately (critical interactivity) -->
<Counter client:load />

<!-- Hydrate when idle (non-critical) -->
<Newsletter client:idle />

<!-- Hydrate when visible (below fold) -->
<Comments client:visible />

<!-- Only hydrate on specific media query -->
<MobileMenu client:media="(max-width: 768px)" />
```

### Inline Scripts
- Use `is:inline` only when necessary
- Prefer external scripts for caching

```astro
<script>
  // Bundled and optimized by default
  document.querySelector('.menu-toggle')?.addEventListener('click', () => {
    // Handle click
  });
</script>
```

## Performance

### Content Collections
- Use content collections for structured content
- Define schemas for type safety

```typescript
// src/content/config.ts
import { defineCollection, z } from 'astro:content';

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    pubDate: z.date(),
    draft: z.boolean().default(false),
  }),
});

export const collections = { blog };
```

### Prefetching
- Enable prefetching for faster navigation
- Be selective to avoid over-fetching

```astro
<a href="/about" data-astro-prefetch>About</a>
<a href="/contact" data-astro-prefetch="viewport">Contact</a>
```
