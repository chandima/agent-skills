---
name: alpine
description: Alpine.js patterns for lightweight reactivity including directives, magics, plugins, and state management. Use when adding interactivity without heavy frameworks.
---

# Alpine.js

Lightweight reactivity for server-first applications. 15KB, handles 95% of interactive needs.

## Core Philosophy

- Use Alpine.js for simple interactivity (toggles, forms, filtering)
- Reserve React/Vue Islands for complex pre-built components
- Keep state close to the DOM
- Extract complex logic to `Alpine.data()`

## Essential Directives

### x-data (State)

```html
<div x-data="{ open: false, count: 0 }">
  <button @click="open = !open">Toggle</button>
  <div x-show="open">Content</div>
</div>
```

### x-show / x-if (Conditional)

```html
<!-- x-show: toggles display, stays in DOM -->
<div x-show="visible" x-transition>Content</div>

<!-- x-if: adds/removes from DOM -->
<template x-if="loggedIn">
  <nav>User navigation</nav>
</template>
```

### x-for (Loops)

```html
<template x-for="item in items" :key="item.id">
  <div x-text="item.name"></div>
</template>
```

### x-model (Two-way Binding)

```html
<input x-model="search" type="text">
<input x-model.debounce.300ms="query">
<input x-model.number="quantity">
```

### x-on / @ (Events)

```html
<button @click="handleClick">Click</button>
<form @submit.prevent="save">...</form>
<input @keydown.enter="search">
<div @click.outside="open = false">...</div>
```

### x-bind / : (Attributes)

```html
<div :class="{ active: isActive }">
<button :disabled="loading">Submit</button>
<img :src="imageUrl">
```

## Magics

```html
<!-- $el: current element -->
<button @click="$el.classList.toggle('active')">

<!-- $refs: element references -->
<input x-ref="search">
<button @click="$refs.search.focus()">

<!-- $dispatch: custom events -->
<button @click="$dispatch('notify', { message: 'Hello' })">

<!-- $store: global state -->
<span x-text="$store.user.name">

<!-- $nextTick: after DOM update -->
<button @click="open = true; $nextTick(() => $refs.input.focus())">
```

## Plugins

### Focus (Modal trapping)
```html
<div x-show="open" x-trap.inert="open">
  <!-- Focus trapped inside -->
</div>
```

### Collapse (Height animations)
```html
<div x-show="open" x-collapse>
  Smooth height animation
</div>
```

### Persist (LocalStorage)
```html
<div x-data="{ theme: $persist('light') }">
```

### Intersect (Visibility)
```html
<div x-intersect="visible = true">
  Lazy load when visible
</div>
```

## Reusable Components

```html
<script>
  Alpine.data('dropdown', () => ({
    open: false,
    toggle() { this.open = !this.open },
    close() { this.open = false }
  }));
</script>

<div x-data="dropdown">
  <button @click="toggle">Menu</button>
  <div x-show="open" @click.outside="close">
    Content
  </div>
</div>
```

## Global State

```html
<script>
  Alpine.store('cart', {
    items: [],
    get total() {
      return this.items.reduce((sum, i) => sum + i.price, 0);
    },
    add(product) {
      this.items.push(product);
    }
  });
</script>

<span x-text="$store.cart.total"></span>
```

## Astro Integration

```astro
---
const products = await getProducts();
---

<!-- Method 1: JSON in x-data -->
<div x-data={`{ products: ${JSON.stringify(products)} }`}>
  ...
</div>

<!-- Method 2: define:vars for stores -->
<script define:vars={{ products }}>
  Alpine.store('products', products);
</script>
```

## Anti-Patterns

```html
<!-- Bad: Too much inline logic -->
<div x-data="{ /* 50 lines */ }">

<!-- Good: Extract to Alpine.data() -->
<div x-data="myComponent">

<!-- Bad: Missing :key in loops -->
<template x-for="item in items">

<!-- Good: Always use :key -->
<template x-for="item in items" :key="item.id">

<!-- Bad: x-html with user input (XSS) -->
<div x-html="userContent">

<!-- Good: Use x-text -->
<div x-text="userContent">
```

## When to Use Islands Instead

- Rich text editors
- Complex drag-and-drop
- Data visualization (charts)
- Pre-built React/Vue components
- Heavy state management

## References

See `.apm/instructions/alpinejs.instructions.md` for complete patterns including:
- All directive modifiers
- Plugin configuration
- Advanced patterns
