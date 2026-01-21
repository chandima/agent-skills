---
applyTo: "**/*.{astro,html}"
description: "Alpine.js patterns for reactive UI with directives, magics, plugins, and Astro integration"
---

# Alpine.js Standards

## Core Directives

### x-data (State)

Initialize component state:

```html
<!-- Simple state -->
<div x-data="{ open: false, count: 0 }">
  ...
</div>

<!-- With methods -->
<div x-data="{
  count: 0,
  increment() { this.count++ },
  decrement() { this.count-- }
}">
  <button @click="decrement">-</button>
  <span x-text="count"></span>
  <button @click="increment">+</button>
</div>

<!-- With getters -->
<div x-data="{
  items: ['a', 'b', 'c'],
  filter: '',
  get filtered() {
    return this.items.filter(i => i.includes(this.filter));
  }
}">
  <input x-model="filter">
  <template x-for="item in filtered">
    <div x-text="item"></div>
  </template>
</div>
```

### x-init (Initialization)

Run code when component initializes:

```html
<!-- Simple init -->
<div x-data="{ users: [] }" x-init="users = await (await fetch('/api/users')).json()">
  ...
</div>

<!-- With $watch -->
<div x-data="{ search: '' }" x-init="$watch('search', value => console.log(value))">
  <input x-model="search">
</div>
```

### x-show and x-if (Conditional Rendering)

```html
<!-- x-show: toggles display (element stays in DOM) -->
<div x-show="open" x-transition>
  Content
</div>

<!-- x-if: adds/removes from DOM (use with template) -->
<template x-if="loggedIn">
  <nav>User navigation</nav>
</template>

<!-- When to use which:
     - x-show: frequently toggled, needs transitions
     - x-if: rarely shown, heavy content, SEO concerns -->
```

### x-for (Loops)

```html
<!-- Basic loop -->
<template x-for="item in items">
  <div x-text="item"></div>
</template>

<!-- With key (required for proper updates) -->
<template x-for="item in items" :key="item.id">
  <div x-text="item.name"></div>
</template>

<!-- With index -->
<template x-for="(item, index) in items" :key="item.id">
  <div>
    <span x-text="index + 1"></span>.
    <span x-text="item.name"></span>
  </div>
</template>

<!-- Nested loops -->
<template x-for="category in categories" :key="category.id">
  <div>
    <h2 x-text="category.name"></h2>
    <template x-for="product in category.products" :key="product.id">
      <div x-text="product.name"></div>
    </template>
  </div>
</template>
```

### x-model (Two-way Binding)

```html
<!-- Text input -->
<input type="text" x-model="name">

<!-- With modifiers -->
<input x-model.lazy="search">           <!-- Update on blur -->
<input x-model.number="quantity">       <!-- Cast to number -->
<input x-model.debounce.300ms="query">  <!-- Debounce 300ms -->
<input x-model.throttle.500ms="scroll"> <!-- Throttle 500ms -->

<!-- Checkbox -->
<input type="checkbox" x-model="subscribed">

<!-- Multiple checkboxes (array) -->
<input type="checkbox" value="option1" x-model="selectedOptions">
<input type="checkbox" value="option2" x-model="selectedOptions">

<!-- Radio buttons -->
<input type="radio" value="small" x-model="size">
<input type="radio" value="medium" x-model="size">
<input type="radio" value="large" x-model="size">

<!-- Select -->
<select x-model="country">
  <option value="us">United States</option>
  <option value="ca">Canada</option>
</select>

<!-- Multiple select -->
<select x-model="countries" multiple>
  <option value="us">United States</option>
  <option value="ca">Canada</option>
</select>
```

### x-on / @ (Events)

```html
<!-- Click -->
<button @click="open = true">Open</button>
<button x-on:click="open = true">Open</button>

<!-- With expression -->
<button @click="count++">Increment</button>

<!-- Call method -->
<button @click="handleClick">Click</button>

<!-- With modifiers -->
<form @submit.prevent="save">...</form>    <!-- Prevent default -->
<button @click.stop="handle">...</button>  <!-- Stop propagation -->
<button @click.once="init">...</button>    <!-- Fire once only -->
<input @keydown.enter="search">            <!-- Key modifiers -->
<input @keydown.escape="close">
<input @keydown.arrow-up="prev">

<!-- Window/document events -->
<div @keydown.escape.window="closeModal">  <!-- Listen on window -->
<div @click.outside="open = false">        <!-- Click outside -->

<!-- Custom events -->
<div @custom-event="handleCustom">
<div @notify.window="showNotification">
```

### x-bind / : (Attribute Binding)

```html
<!-- Class binding -->
<div :class="{ 'active': isActive, 'error': hasError }">
<div :class="isActive ? 'bg-blue-500' : 'bg-gray-500'">
<div :class="[baseClass, isActive && 'active']">

<!-- Style binding -->
<div :style="{ color: textColor, fontSize: size + 'px' }">

<!-- Other attributes -->
<button :disabled="loading">Submit</button>
<input :placeholder="placeholder">
<img :src="imageUrl" :alt="imageAlt">
<a :href="link">Link</a>

<!-- Boolean attributes -->
<input :required="isRequired">
<input :readonly="isReadonly">
<details :open="isExpanded">
```

### x-text and x-html

```html
<!-- Text content (escaped) -->
<span x-text="message"></span>
<span x-text="'Hello, ' + name"></span>
<span x-text="count > 0 ? count : 'None'"></span>

<!-- HTML content (use carefully, XSS risk) -->
<div x-html="htmlContent"></div>
```

### x-transition (Animations)

```html
<!-- Basic transition -->
<div x-show="open" x-transition>
  Content with fade
</div>

<!-- Customized -->
<div
  x-show="open"
  x-transition:enter="transition ease-out duration-300"
  x-transition:enter-start="opacity-0 transform scale-90"
  x-transition:enter-end="opacity-100 transform scale-100"
  x-transition:leave="transition ease-in duration-200"
  x-transition:leave-start="opacity-100 transform scale-100"
  x-transition:leave-end="opacity-0 transform scale-90"
>
  Custom animated content
</div>

<!-- With modifiers -->
<div x-show="open" x-transition.duration.500ms>
<div x-show="open" x-transition.opacity>
<div x-show="open" x-transition.scale.80>
```

### x-ref (Element References)

```html
<div x-data="{ focus() { this.$refs.input.focus() } }">
  <input x-ref="input" type="text">
  <button @click="focus">Focus Input</button>
</div>
```

### x-cloak (Hide Until Ready)

```html
<!-- Add to CSS: [x-cloak] { display: none !important; } -->
<div x-data="{ ready: false }" x-cloak>
  <!-- Hidden until Alpine initializes -->
</div>
```

## Magics

### $el (Current Element)

```html
<button @click="$el.classList.toggle('active')">Toggle</button>
<div x-init="console.log($el.offsetWidth)">...</div>
```

### $refs (Element References)

```html
<div x-data>
  <input x-ref="search" type="text">
  <button @click="$refs.search.focus()">Focus</button>
</div>
```

### $watch (Reactive Watcher)

```html
<div x-data="{ search: '' }" x-init="
  $watch('search', (value, oldValue) => {
    console.log('Changed from', oldValue, 'to', value);
  })
">
  <input x-model="search">
</div>
```

### $dispatch (Custom Events)

```html
<!-- Dispatch event -->
<button @click="$dispatch('notify', { message: 'Hello!' })">
  Notify
</button>

<!-- Listen for event -->
<div @notify.window="alert($event.detail.message)">
  ...
</div>

<!-- Parent-child communication -->
<div x-data @item-selected="selectedId = $event.detail.id">
  <template x-for="item in items">
    <button @click="$dispatch('item-selected', { id: item.id })">
      <span x-text="item.name"></span>
    </button>
  </template>
</div>
```

### $nextTick (After DOM Update)

```html
<div x-data="{ open: false }">
  <button @click="open = true; $nextTick(() => $refs.input.focus())">
    Open and Focus
  </button>
  <div x-show="open">
    <input x-ref="input" type="text">
  </div>
</div>
```

### $store (Global State)

```html
<script>
  document.addEventListener('alpine:init', () => {
    Alpine.store('user', {
      name: 'Guest',
      loggedIn: false,
      login(name) {
        this.name = name;
        this.loggedIn = true;
      },
      logout() {
        this.name = 'Guest';
        this.loggedIn = false;
      }
    });
  });
</script>

<!-- Access anywhere -->
<div x-data>
  <span x-text="$store.user.name"></span>
  <button x-show="!$store.user.loggedIn" @click="$store.user.login('John')">
    Login
  </button>
  <button x-show="$store.user.loggedIn" @click="$store.user.logout()">
    Logout
  </button>
</div>
```

### $data and $root

```html
<!-- $data: access current component's data -->
<div x-data="{ items: [] }" x-init="console.log($data)">

<!-- $root: reference to root element of component -->
<div x-data="{ ... }">
  <button @click="$root.classList.add('modified')">
</div>
```

## Plugins

### Mask (Input Formatting)

```html
<script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/mask@3.x.x/dist/cdn.min.js"></script>

<!-- Phone number -->
<input x-mask="(999) 999-9999" placeholder="(555) 555-5555">

<!-- Date -->
<input x-mask="99/99/9999" placeholder="MM/DD/YYYY">

<!-- Credit card -->
<input x-mask="9999 9999 9999 9999">

<!-- Dynamic mask -->
<input x-mask:dynamic="$input.startsWith('1') ? '1 999 999 9999' : '999 999 9999'">

<!-- Currency -->
<input x-mask:dynamic="$money($input, ',', ' ')">
```

### Intersect (Visibility Detection)

```html
<script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/intersect@3.x.x/dist/cdn.min.js"></script>

<!-- Lazy load when visible -->
<div x-data="{ shown: false }" x-intersect="shown = true">
  <template x-if="shown">
    <img src="large-image.jpg">
  </template>
</div>

<!-- Animation on scroll -->
<div 
  x-data="{ visible: false }"
  x-intersect:enter="visible = true"
  :class="visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'"
  class="transition duration-500"
>
  Fade in on scroll
</div>

<!-- Infinite scroll -->
<div x-data="{ items: [], page: 1 }">
  <template x-for="item in items">
    <div x-text="item.name"></div>
  </template>
  <div x-intersect="loadMore()">Loading more...</div>
</div>

<!-- With threshold -->
<div x-intersect.half="handleHalfVisible">   <!-- 50% visible -->
<div x-intersect.full="handleFullyVisible">  <!-- 100% visible -->
```

### Persist (LocalStorage Sync)

```html
<script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/persist@3.x.x/dist/cdn.min.js"></script>

<!-- Persist to localStorage -->
<div x-data="{ theme: $persist('light') }">
  <button @click="theme = theme === 'light' ? 'dark' : 'light'">
    Toggle Theme
  </button>
</div>

<!-- With custom key -->
<div x-data="{ count: $persist(0).as('my-counter') }">

<!-- Using sessionStorage -->
<div x-data="{ temp: $persist('').using(sessionStorage) }">
```

### Focus (Focus Management)

```html
<script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/focus@3.x.x/dist/cdn.min.js"></script>

<!-- Focus trap (for modals) -->
<div x-data="{ open: false }">
  <button @click="open = true">Open Modal</button>
  
  <div x-show="open" x-trap="open">
    <h2>Modal Title</h2>
    <input type="text" placeholder="Trapped focus...">
    <button @click="open = false">Close</button>
  </div>
</div>

<!-- With inert (disables outside content) -->
<div x-show="open" x-trap.inert="open">

<!-- No scroll (prevents body scroll) -->
<div x-show="open" x-trap.noscroll="open">

<!-- Initial focus -->
<div x-show="open" x-trap="open">
  <input x-init="$focus.focus()" type="text">
</div>
```

### Collapse (Height Animations)

```html
<script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/collapse@3.x.x/dist/cdn.min.js"></script>

<!-- Accordion -->
<div x-data="{ open: false }">
  <button @click="open = !open">Toggle</button>
  <div x-show="open" x-collapse>
    <p>This content smoothly collapses/expands</p>
  </div>
</div>

<!-- With duration -->
<div x-show="open" x-collapse.duration.500ms>

<!-- Minimum height -->
<div x-show="open" x-collapse.min.50px>
```

## Reusable Patterns

### Alpine.data() (Component Registration)

```html
<script>
  document.addEventListener('alpine:init', () => {
    Alpine.data('dropdown', () => ({
      open: false,
      toggle() {
        this.open = !this.open;
      },
      close() {
        this.open = false;
      }
    }));
    
    Alpine.data('tabs', (initialTab = 'tab1') => ({
      activeTab: initialTab,
      isActive(tab) {
        return this.activeTab === tab;
      },
      setTab(tab) {
        this.activeTab = tab;
      }
    }));
  });
</script>

<!-- Use components -->
<div x-data="dropdown">
  <button @click="toggle">Menu</button>
  <div x-show="open" @click.outside="close">
    Dropdown content
  </div>
</div>

<div x-data="tabs('settings')">
  <button @click="setTab('profile')" :class="isActive('profile') && 'active'">Profile</button>
  <button @click="setTab('settings')" :class="isActive('settings') && 'active'">Settings</button>
</div>
```

### Alpine.store() (Global State)

```html
<script>
  document.addEventListener('alpine:init', () => {
    Alpine.store('cart', {
      items: [],
      get total() {
        return this.items.reduce((sum, item) => sum + item.price * item.qty, 0);
      },
      add(product) {
        const existing = this.items.find(i => i.id === product.id);
        if (existing) {
          existing.qty++;
        } else {
          this.items.push({ ...product, qty: 1 });
        }
      },
      remove(id) {
        this.items = this.items.filter(i => i.id !== id);
      }
    });
  });
</script>

<!-- Access from any component -->
<div x-data>
  <span x-text="$store.cart.items.length"></span> items
  <span x-text="'$' + $store.cart.total.toFixed(2)"></span>
</div>
```

## Astro Integration

### Passing Data from Astro

```astro
---
const products = await getProducts();
const user = await getUser();
---

<!-- Method 1: JSON.stringify in x-data -->
<div x-data={`{ products: ${JSON.stringify(products)} }`}>
  <template x-for="product in products" :key="product.id">
    <div x-text="product.name"></div>
  </template>
</div>

<!-- Method 2: define:vars for complex data -->
<script define:vars={{ products, user }}>
  document.addEventListener('alpine:init', () => {
    Alpine.store('products', products);
    Alpine.store('user', user);
  });
</script>

<div x-data>
  <template x-for="product in $store.products" :key="product.id">
    <div x-text="product.name"></div>
  </template>
</div>
```

### Script Loading Order

```astro
---
// Astro component
---

<html>
<head>
  <!-- Load Alpine plugins first -->
  <script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/persist@3.x.x/dist/cdn.min.js"></script>
  <script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/focus@3.x.x/dist/cdn.min.js"></script>
  
  <!-- Then Alpine core -->
  <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
</head>
<body>
  <!-- Alpine components here -->
</body>
</html>
```

### Module Script with Alpine

```astro
<script>
  import Alpine from 'alpinejs';
  import persist from '@alpinejs/persist';
  import focus from '@alpinejs/focus';
  
  Alpine.plugin(persist);
  Alpine.plugin(focus);
  
  // Register components before starting
  Alpine.data('myComponent', () => ({
    // ...
  }));
  
  Alpine.start();
</script>
```

## Anti-Patterns

### Avoid These Patterns

```html
<!-- Bad: Too much logic inline -->
<div x-data="{
  items: [],
  loading: false,
  error: null,
  async fetchItems() { /* 20 lines of code */ },
  async createItem() { /* 20 lines of code */ },
  async updateItem() { /* 20 lines of code */ },
  async deleteItem() { /* 20 lines of code */ },
}">

<!-- Good: Extract to Alpine.data() -->
<script>
  Alpine.data('itemList', () => ({ /* ... */ }));
</script>
<div x-data="itemList">


<!-- Bad: Deeply nested x-data -->
<div x-data="{ a: 1 }">
  <div x-data="{ b: 2 }">
    <div x-data="{ c: 3 }">
      <!-- Hard to track state -->
    </div>
  </div>
</div>

<!-- Good: Flat structure with stores -->
<div x-data>
  <span x-text="$store.app.value"></span>
</div>


<!-- Bad: Using x-html with user input (XSS) -->
<div x-html="userProvidedContent"></div>

<!-- Good: Use x-text for user content -->
<div x-text="userProvidedContent"></div>


<!-- Bad: Not using :key in x-for -->
<template x-for="item in items">
  <div x-text="item.name"></div>
</template>

<!-- Good: Always use :key -->
<template x-for="item in items" :key="item.id">
  <div x-text="item.name"></div>
</template>
```

## When to Use Alpine vs Islands

### Use Alpine.js When:
- Simple toggles, dropdowns, tabs, accordions
- Form validation and submission
- Data filtering and sorting
- Basic animations and transitions
- State that doesn't need React ecosystem

### Use Astro Islands When:
- Need a pre-built React/Vue component (charts, editors, calendars)
- Complex drag-and-drop
- Rich text editing
- Component has many React dependencies
- Team is already proficient in React/Vue

```astro
<!-- Alpine: Simple dropdown -->
<div x-data="{ open: false }" class="dropdown">
  <button @click="open = !open">Menu</button>
  <div x-show="open" @click.outside="open = false">
    <a href="/profile">Profile</a>
    <a href="/settings">Settings</a>
  </div>
</div>

<!-- Island: Complex rich-text editor -->
---
import TipTapEditor from '@/components/TipTapEditor.tsx';
---
<TipTapEditor client:idle content={initialContent} />
```
