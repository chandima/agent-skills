---
applyTo: "**/*.astro"
description: "Astro patterns with Alpine.js, Basecoat UI, Islands architecture, and SST integration"
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

## Basecoat UI

Basecoat is a component library built with Tailwind CSS that provides shadcn/ui-like components without React. Use these class-based components with Alpine.js for interactivity.

### Installation

```bash
npx basecoat@latest init
npx basecoat@latest add button card dialog
```

### Component Categories

#### Layout Components

```astro
<!-- Card -->
<div class="card">
  <div class="card-header">
    <h3 class="card-title">Card Title</h3>
    <p class="card-description">Card description</p>
  </div>
  <div class="card-content">
    Main content here
  </div>
  <div class="card-footer">
    <button class="btn btn-primary">Action</button>
  </div>
</div>

<!-- Sidebar -->
<aside class="sidebar">
  <div class="sidebar-header">
    <img src="/logo.svg" alt="Logo">
  </div>
  <nav class="sidebar-content">
    <a href="/" class="sidebar-item active">Dashboard</a>
    <a href="/settings" class="sidebar-item">Settings</a>
  </nav>
  <div class="sidebar-footer">
    <button class="btn btn-ghost">Logout</button>
  </div>
</aside>
```

#### Form Components

```astro
<!-- Input with Field wrapper -->
<div class="field">
  <label for="email" class="label">Email</label>
  <input type="email" id="email" class="input" placeholder="you@example.com">
  <p class="field-description">We'll never share your email.</p>
</div>

<!-- Input with error -->
<div class="field">
  <label for="password" class="label">Password</label>
  <input type="password" id="password" class="input input-error">
  <p class="field-error">Password must be at least 8 characters.</p>
</div>

<!-- Input Group -->
<div class="input-group">
  <span class="input-group-text">$</span>
  <input type="number" class="input" placeholder="0.00">
  <span class="input-group-text">USD</span>
</div>

<!-- Select -->
<select class="select">
  <option value="">Choose an option</option>
  <option value="1">Option 1</option>
  <option value="2">Option 2</option>
</select>

<!-- Checkbox -->
<label class="checkbox">
  <input type="checkbox" class="checkbox-input">
  <span class="checkbox-label">Accept terms and conditions</span>
</label>

<!-- Radio Group -->
<div class="radio-group">
  <label class="radio">
    <input type="radio" name="size" value="sm" class="radio-input">
    <span class="radio-label">Small</span>
  </label>
  <label class="radio">
    <input type="radio" name="size" value="md" class="radio-input">
    <span class="radio-label">Medium</span>
  </label>
</div>

<!-- Switch -->
<label class="switch">
  <input type="checkbox" class="switch-input">
  <span class="switch-slider"></span>
  <span class="switch-label">Enable notifications</span>
</label>

<!-- Textarea -->
<textarea class="textarea" rows="4" placeholder="Enter your message"></textarea>

<!-- Slider -->
<input type="range" class="slider" min="0" max="100" value="50">
```

#### Button Variants

```astro
<button class="btn btn-primary">Primary</button>
<button class="btn btn-secondary">Secondary</button>
<button class="btn btn-outline">Outline</button>
<button class="btn btn-ghost">Ghost</button>
<button class="btn btn-destructive">Destructive</button>
<button class="btn btn-link">Link</button>

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

<!-- Button Group -->
<div class="btn-group">
  <button class="btn btn-outline">Left</button>
  <button class="btn btn-outline">Center</button>
  <button class="btn btn-outline">Right</button>
</div>
```

#### Feedback Components

```astro
<!-- Alert -->
<div class="alert">
  <svg class="alert-icon">...</svg>
  <div class="alert-content">
    <h4 class="alert-title">Heads up!</h4>
    <p class="alert-description">You can add components to your app using the cli.</p>
  </div>
</div>

<div class="alert alert-error">...</div>
<div class="alert alert-warning">...</div>
<div class="alert alert-success">...</div>

<!-- Progress -->
<div class="progress">
  <div class="progress-bar" style="width: 60%"></div>
</div>

<!-- Spinner -->
<div class="spinner"></div>
<div class="spinner spinner-sm"></div>

<!-- Skeleton -->
<div class="skeleton h-4 w-full"></div>
<div class="skeleton h-4 w-3/4"></div>
<div class="skeleton h-32 w-full rounded-lg"></div>

<!-- Toast (with Alpine.js) -->
<div x-data="{ show: false, message: '' }" 
     @toast.window="show = true; message = $event.detail.message; setTimeout(() => show = false, 3000)">
  <div x-show="show" x-transition class="toast">
    <span x-text="message"></span>
  </div>
</div>
```

#### Overlay Components

```astro
<!-- Dialog with Alpine.js -->
<div x-data="{ open: false }">
  <button @click="open = true" class="btn btn-primary">Open Dialog</button>
  
  <div x-show="open" x-cloak class="dialog-overlay" @click.self="open = false">
    <div class="dialog" x-trap.inert="open">
      <div class="dialog-header">
        <h2 class="dialog-title">Dialog Title</h2>
        <button @click="open = false" class="btn btn-ghost btn-icon-only">
          <span class="sr-only">Close</span>
          ✕
        </button>
      </div>
      <div class="dialog-content">
        <p>Dialog content goes here.</p>
      </div>
      <div class="dialog-footer">
        <button @click="open = false" class="btn btn-outline">Cancel</button>
        <button class="btn btn-primary">Confirm</button>
      </div>
    </div>
  </div>
</div>

<!-- Alert Dialog -->
<div x-data="{ open: false }">
  <button @click="open = true" class="btn btn-destructive">Delete</button>
  
  <div x-show="open" x-cloak class="dialog-overlay">
    <div class="alert-dialog" role="alertdialog">
      <h2 class="alert-dialog-title">Are you sure?</h2>
      <p class="alert-dialog-description">This action cannot be undone.</p>
      <div class="alert-dialog-footer">
        <button @click="open = false" class="btn btn-outline">Cancel</button>
        <button @click="deleteItem(); open = false" class="btn btn-destructive">Delete</button>
      </div>
    </div>
  </div>
</div>

<!-- Dropdown Menu -->
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

<!-- Popover -->
<div x-data="{ open: false }" class="popover-container">
  <button @click="open = !open" class="btn btn-outline">Show Popover</button>
  <div x-show="open" @click.outside="open = false" class="popover">
    <h4 class="popover-title">Popover Title</h4>
    <p class="popover-content">Popover content here.</p>
  </div>
</div>

<!-- Tooltip -->
<div x-data="{ show: false }" class="tooltip-container">
  <button @mouseenter="show = true" @mouseleave="show = false" class="btn">
    Hover me
  </button>
  <div x-show="show" x-transition.opacity class="tooltip">
    Tooltip text
  </div>
</div>

<!-- Command Palette -->
<div x-data="{ open: false, search: '' }" @keydown.meta.k.window="open = true">
  <div x-show="open" x-cloak class="dialog-overlay">
    <div class="command" x-trap.inert="open">
      <input x-model="search" class="command-input" placeholder="Type a command...">
      <div class="command-list">
        <div class="command-group">
          <div class="command-group-heading">Suggestions</div>
          <button class="command-item">Calendar</button>
          <button class="command-item">Settings</button>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Combobox -->
<div x-data="{ open: false, search: '', selected: null, items: ['Apple', 'Banana', 'Cherry'] }">
  <div class="combobox">
    <input 
      x-model="search"
      @focus="open = true"
      class="input"
      placeholder="Select fruit..."
    >
    <div x-show="open" @click.outside="open = false" class="combobox-options">
      <template x-for="item in items.filter(i => i.toLowerCase().includes(search.toLowerCase()))">
        <button 
          @click="selected = item; search = item; open = false"
          class="combobox-option"
          x-text="item"
        ></button>
      </template>
    </div>
  </div>
</div>
```

#### Navigation Components

```astro
<!-- Tabs with Alpine.js -->
<div x-data="{ tab: 'account' }">
  <div class="tabs">
    <button @click="tab = 'account'" :class="tab === 'account' && 'tab-active'" class="tab">
      Account
    </button>
    <button @click="tab = 'password'" :class="tab === 'password' && 'tab-active'" class="tab">
      Password
    </button>
  </div>
  
  <div x-show="tab === 'account'" class="tab-content">
    Account settings...
  </div>
  <div x-show="tab === 'password'" class="tab-content">
    Password settings...
  </div>
</div>

<!-- Accordion -->
<div x-data="{ open: null }" class="accordion">
  <div class="accordion-item">
    <button @click="open = open === 1 ? null : 1" class="accordion-trigger">
      Section 1
      <svg :class="open === 1 && 'rotate-180'" class="accordion-chevron">...</svg>
    </button>
    <div x-show="open === 1" x-collapse class="accordion-content">
      Content for section 1
    </div>
  </div>
  <div class="accordion-item">
    <button @click="open = open === 2 ? null : 2" class="accordion-trigger">
      Section 2
    </button>
    <div x-show="open === 2" x-collapse class="accordion-content">
      Content for section 2
    </div>
  </div>
</div>

<!-- Breadcrumb -->
<nav class="breadcrumb">
  <a href="/" class="breadcrumb-item">Home</a>
  <span class="breadcrumb-separator">/</span>
  <a href="/products" class="breadcrumb-item">Products</a>
  <span class="breadcrumb-separator">/</span>
  <span class="breadcrumb-item breadcrumb-current">Widget</span>
</nav>

<!-- Pagination -->
<nav class="pagination">
  <button class="pagination-prev" disabled>Previous</button>
  <button class="pagination-item">1</button>
  <button class="pagination-item pagination-active">2</button>
  <button class="pagination-item">3</button>
  <span class="pagination-ellipsis">...</span>
  <button class="pagination-item">10</button>
  <button class="pagination-next">Next</button>
</nav>
```

#### Data Display

```astro
<!-- Table -->
<div class="table-container">
  <table class="table">
    <thead>
      <tr>
        <th>Name</th>
        <th>Email</th>
        <th>Status</th>
        <th class="text-right">Actions</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>John Doe</td>
        <td>john@example.com</td>
        <td><span class="badge badge-success">Active</span></td>
        <td class="text-right">
          <button class="btn btn-ghost btn-sm">Edit</button>
        </td>
      </tr>
    </tbody>
  </table>
</div>

<!-- Avatar -->
<div class="avatar">
  <img src="/user.jpg" alt="User">
</div>
<div class="avatar avatar-sm">
  <span class="avatar-fallback">JD</span>
</div>

<!-- Badge -->
<span class="badge">Default</span>
<span class="badge badge-primary">Primary</span>
<span class="badge badge-secondary">Secondary</span>
<span class="badge badge-success">Success</span>
<span class="badge badge-warning">Warning</span>
<span class="badge badge-error">Error</span>

<!-- Kbd -->
<kbd class="kbd">⌘</kbd> + <kbd class="kbd">K</kbd>

<!-- Empty State -->
<div class="empty">
  <svg class="empty-icon">...</svg>
  <h3 class="empty-title">No results found</h3>
  <p class="empty-description">Try adjusting your search or filters.</p>
  <button class="btn btn-primary">Clear filters</button>
</div>
```

#### Theme Switcher

```astro
<div x-data="{ 
  theme: localStorage.getItem('theme') || 'system',
  setTheme(t) {
    this.theme = t;
    localStorage.setItem('theme', t);
    if (t === 'dark' || (t === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }
}" x-init="setTheme(theme)">
  <div class="theme-switcher">
    <button @click="setTheme('light')" :class="theme === 'light' && 'active'" class="theme-switcher-btn">
      ☀️ Light
    </button>
    <button @click="setTheme('dark')" :class="theme === 'dark' && 'active'" class="theme-switcher-btn">
      🌙 Dark
    </button>
    <button @click="setTheme('system')" :class="theme === 'system' && 'active'" class="theme-switcher-btn">
      💻 System
    </button>
  </div>
</div>
```

## Alpine.js Integration

### Passing Data from Astro to Alpine

```astro
---
const products = await getProducts();
const user = Astro.locals.user;
---

<!-- Method 1: JSON in x-data -->
<div x-data={`{ products: ${JSON.stringify(products)}, user: ${JSON.stringify(user)} }`}>
  <p>Welcome, <span x-text="user.name"></span></p>
  <template x-for="product in products" :key="product.id">
    <div x-text="product.name"></div>
  </template>
</div>

<!-- Method 2: define:vars for global stores -->
<script define:vars={{ products, user }}>
  document.addEventListener('alpine:init', () => {
    Alpine.store('products', products);
    Alpine.store('user', user);
  });
</script>

<div x-data>
  <p>Welcome, <span x-text="$store.user.name"></span></p>
</div>
```

### Component Pattern: Basecoat + Alpine

```astro
---
interface Props {
  items: { id: string; name: string }[];
  selected?: string;
}

const { items, selected } = Astro.props;
---

<div 
  x-data={`{ 
    selected: ${JSON.stringify(selected || null)},
    items: ${JSON.stringify(items)},
    select(id) {
      this.selected = id;
      this.$dispatch('selection-change', { id });
    }
  }`}
  class="space-y-2"
>
  <template x-for="item in items" :key="item.id">
    <button 
      @click="select(item.id)"
      :class="selected === item.id ? 'btn-primary' : 'btn-outline'"
      class="btn w-full justify-start"
      x-text="item.name"
    ></button>
  </template>
</div>
```

## Islands Architecture

Use Islands when Alpine.js isn't sufficient. This typically means pre-built React/Vue components or very complex state management.

### Decision Matrix

| Need | Use Alpine.js | Use Island |
|------|---------------|------------|
| Toggle, dropdown, tabs | ✅ | |
| Form validation | ✅ | |
| Data filtering/sorting | ✅ | |
| Simple animations | ✅ | |
| Rich text editor | | ✅ |
| Complex drag-and-drop | | ✅ |
| Data visualization (charts) | | ✅ |
| Pre-built React component | | ✅ |

### Hydration Strategies

```astro
---
import ReactCalendar from '@/components/Calendar.tsx';
import VueEditor from '@/components/Editor.vue';
import SolidChart from '@/components/Chart.tsx';
---

<!-- client:load - Hydrate immediately -->
<!-- Use for: Critical UI (auth buttons, navigation toggles) -->
<AuthButton client:load user={user} />

<!-- client:idle - Hydrate when browser is idle -->
<!-- Use for: Non-critical forms, widgets -->
<NewsletterSignup client:idle />
<ChatWidget client:idle />

<!-- client:visible - Hydrate when scrolled into view -->
<!-- Use for: Below-fold content, heavy components -->
<ReactCalendar client:visible events={events} />
<CommentsSection client:visible postId={post.id} />
<VueEditor client:visible content={content} />

<!-- client:media - Hydrate on media query match -->
<!-- Use for: Mobile-only or desktop-only components -->
<MobileNavigation client:media="(max-width: 768px)" />
<DesktopSidebar client:media="(min-width: 1024px)" />

<!-- client:only - Skip SSR, client-render only -->
<!-- Use for: Components that can't SSR (browser APIs) -->
<MapComponent client:only="react" />
```

### Framework Selection for Islands

When you must use an Island:

| Framework | Best For | Bundle Size Impact |
|-----------|----------|-------------------|
| React | Largest ecosystem, most pre-built components | Largest (~40KB) |
| Vue | Good component libraries, SFC syntax | Medium (~30KB) |
| Solid | Performance-critical Islands | Smallest (~7KB) |
| Svelte | Simple Islands, small bundle | Very small (~2KB) |

```astro
---
// Pick the framework based on the component you need
import ReactDatePicker from 'react-datepicker';    // React ecosystem
import TipTapEditor from '@/components/Editor.vue'; // Vue for editors
import SolidChart from '@/components/Chart.tsx';    // Solid for performance
---

<ReactDatePicker client:idle selected={date} />
<TipTapEditor client:visible content={content} />
<SolidChart client:visible data={chartData} />
```

### Communicating Between Alpine and Islands

```astro
---
import ReactDatePicker from '@/components/DatePicker.tsx';
---

<div x-data="{ selectedDate: null }">
  <!-- Island dispatches custom event -->
  <ReactDatePicker 
    client:idle 
    onDateChange="(date) => window.dispatchEvent(new CustomEvent('date-selected', { detail: { date } }))"
  />
  
  <!-- Alpine listens for the event -->
  <div @date-selected.window="selectedDate = $event.detail.date">
    <p>Selected: <span x-text="selectedDate || 'None'"></span></p>
  </div>
</div>
```

## SST Integration

When using SST for deployment, access linked resources in your Astro API routes.

### Accessing Resources

```astro
---
// src/pages/api/upload.ts
import type { APIRoute } from 'astro';
import { Resource } from 'sst';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';

export const POST: APIRoute = async ({ request }) => {
  const formData = await request.formData();
  const file = formData.get('file') as File;
  
  const client = new S3Client({});
  await client.send(new PutObjectCommand({
    Bucket: Resource.Uploads.name,
    Key: `uploads/${Date.now()}-${file.name}`,
    Body: Buffer.from(await file.arrayBuffer()),
    ContentType: file.type,
  }));
  
  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
};
---
```

### Environment Variables from SST

```astro
---
// Access public environment variables set by SST
const apiUrl = import.meta.env.PUBLIC_API_URL;
---

<script define:vars={{ apiUrl }}>
  window.API_URL = apiUrl;
</script>
```

### Protected Routes with SST Auth

```astro
---
// src/middleware.ts
import { defineMiddleware } from 'astro:middleware';
import { Resource } from 'sst';

export const onRequest = defineMiddleware(async ({ cookies, locals, url }, next) => {
  const token = cookies.get('auth_token')?.value;
  
  if (url.pathname.startsWith('/dashboard')) {
    if (!token) {
      return Response.redirect(new URL('/login', url));
    }
    
    // Verify token with your auth logic
    const user = await verifyToken(token);
    if (!user) {
      return Response.redirect(new URL('/login', url));
    }
    
    locals.user = user;
  }
  
  return next();
});
---
```
