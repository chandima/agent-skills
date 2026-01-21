---
name: astro
description: Astro framework patterns with components, layouts, content collections, and image optimization. Use when building static-first web applications with Astro.
---

# Astro Framework

Astro patterns for server-first, static-by-default web applications.

## Core Philosophy

- Server-first: Render on the server by default
- Zero JS by default: Add interactivity only where needed
- Content-focused: Excellent for content-driven sites
- Island architecture: Hydrate only what needs interactivity

## Component Structure

```astro
---
// 1. Imports
import Layout from '@/layouts/Layout.astro';

// 2. Props interface
interface Props {
  title: string;
  description?: string;
}

// 3. Props destructuring
const { title, description = 'Default' } = Astro.props;

// 4. Data fetching
const posts = await getPosts();
---

<!-- 5. Template -->
<Layout title={title}>
  <h1>{title}</h1>
</Layout>

<!-- 6. Scoped styles -->
<style>
  h1 { color: blue; }
</style>
```

## Client Directives

Choose the right hydration strategy:

```astro
<!-- Immediately (critical UI) -->
<AuthButton client:load />

<!-- When idle (non-critical) -->
<Newsletter client:idle />

<!-- When visible (below fold) -->
<Comments client:visible />

<!-- On media query -->
<MobileMenu client:media="(max-width: 768px)" />
```

## Content Collections

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

## Image Optimization

```astro
---
import { Image } from 'astro:assets';
import heroImage from '@/assets/hero.jpg';
---

<Image 
  src={heroImage}
  alt="Description"
  width={1200}
  height={630}
  loading="eager"
/>
```

## API Routes

```typescript
// src/pages/api/hello.ts
import type { APIRoute } from 'astro';

export const GET: APIRoute = async ({ request }) => {
  return new Response(JSON.stringify({ message: 'Hello' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
};
```

## Middleware

```typescript
// src/middleware.ts
import { defineMiddleware } from 'astro:middleware';

export const onRequest = defineMiddleware(async ({ locals, url }, next) => {
  // Auth check, etc.
  return next();
});
```

## Decision: Alpine.js vs Islands

| Need | Use Alpine.js | Use Island |
|------|---------------|------------|
| Toggle, dropdown, tabs | ✅ | |
| Form validation | ✅ | |
| Data filtering | ✅ | |
| Rich text editor | | ✅ |
| Complex charts | | ✅ |
| Pre-built React component | | ✅ |

## Alpine.js Integration

```astro
---
const products = await getProducts();
---

<div x-data={`{ products: ${JSON.stringify(products)} }`}>
  <template x-for="product in products" :key="product.id">
    <div x-text="product.name"></div>
  </template>
</div>
```

## SST Integration

When deploying Astro with SST, configure the dev command to prevent recursion:

```typescript
// sst.config.ts
new sst.aws.Astro("Web", {
  link: [bucket],
  dev: {
    command: "astro dev",
  },
});
```

Access linked resources in API routes:

```typescript
// src/pages/api/upload.ts
import { Resource } from 'sst';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';

export const POST: APIRoute = async ({ request }) => {
  const client = new S3Client({});
  await client.send(new PutObjectCommand({
    Bucket: Resource.Uploads.name,
    Key: 'file.txt',
    Body: await request.text(),
  }));
  return new Response('OK');
};
```

## Tailwind Class Order

Order consistently:
1. Layout (display, position, flex/grid)
2. Sizing (width, height, padding, margin)
3. Typography (font, text)
4. Visual (background, border, shadow)
5. Interactive (hover, focus, transition)

```astro
<div class="flex items-center p-4 text-lg bg-white rounded-lg hover:shadow-md transition">
```

## Accessibility

- Use semantic HTML (`<nav>`, `<main>`, `<article>`)
- Provide alt text for images
- Use proper heading hierarchy
- Add `aria-label` for icon-only buttons
- Maintain focus indicators

## References

See `.apm/instructions/astro.instructions.md` for complete patterns including:
- Basecoat UI components
- Islands architecture details
- SST integration patterns
