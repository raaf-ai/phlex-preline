# Tailwind CSS Setup for Phlex-Preline

This gem requires Tailwind CSS to be properly configured in your Rails application. Here's how to ensure all component classes are included.

## Required Tailwind Configuration

### 1. Update your `tailwind.config.js`

Add the gem's component paths to your content configuration:

```javascript
module.exports = {
  content: [
    './app/views/**/*.{erb,haml,html,slim}',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
    './app/components/**/*.rb',
    // Add Phlex-Preline gem paths
    './vendor/bundle/**/phlex-preline/app/components/**/*.rb',
    './node_modules/phlex-preline/app/components/**/*.rb',
    // Or if you're using a specific path:
    // './vendor/ruby/*/gems/phlex-preline-*/app/components/**/*.rb',
  ],
  theme: {
    extend: {
      // Ensure these utilities are available
      gridTemplateColumns: {
        // File upload gallery columns
        '2': 'repeat(2, minmax(0, 1fr))',
        '3': 'repeat(3, minmax(0, 1fr))',
        '4': 'repeat(4, minmax(0, 1fr))',
        '5': 'repeat(5, minmax(0, 1fr))',
        '6': 'repeat(6, minmax(0, 1fr))',
      },
    },
  },
  plugins: [],
}
```

### 2. Safelist Critical Dynamic Classes

Some classes are dynamically generated and should be safelisted:

```javascript
module.exports = {
  content: [
    // ... your content paths
  ],
  safelist: [
    // Dynamic grid columns for file upload gallery
    'grid-cols-2',
    'grid-cols-3',
    'grid-cols-4',
    'grid-cols-5',
    'grid-cols-6',
    // Dynamic preview sizes for single image upload
    'size-20',
    'size-32',
    'size-40',
    // Status-based colors
    'border-green-200',
    'border-red-200',
    'text-green-600',
    'text-red-600',
    // File upload states
    'bg-blue-50',
    'border-blue-500',
  ],
  // ... rest of config
}
```

### 3. Alternative: Use Regular Expressions

For more comprehensive coverage, use pattern matching:

```javascript
module.exports = {
  content: [
    // ... your content paths
  ],
  safelist: [
    // Grid columns
    {
      pattern: /grid-cols-(2|3|4|5|6)/,
    },
    // Size utilities
    {
      pattern: /size-(4|10|14|20|32|40)/,
    },
    // Color variants for states
    {
      pattern: /(bg|text|border)-(green|red|blue)-(50|100|200|500|600|700|800)/,
      variants: ['hover'],
    },
  ],
  // ... rest of config
}
```

## Required Base Classes

Ensure your Tailwind base installation includes these utilities:

### Layout & Spacing
- Flexbox: `flex`, `inline-flex`, `items-center`, `justify-center`, etc.
- Grid: `grid`, `gap-*`
- Spacing: `p-*`, `m-*`, `space-*`
- Sizing: `w-*`, `h-*`, `size-*`

### Typography
- Font sizes: `text-xs`, `text-sm`, `text-base`
- Font weights: `font-medium`

### Borders & Backgrounds
- Border styles: `border`, `border-2`, `border-dashed`
- Border radius: `rounded`, `rounded-lg`, `rounded-full`
- Background colors: `bg-white`, `bg-gray-*`, `bg-green-*`, `bg-red-*`, `bg-blue-*`

### Interactive States
- Hover variants: `hover:bg-*`, `hover:border-*`, `hover:text-*`
- Focus variants: `focus:outline-none`, `focus:ring-*`
- Disabled variants: `disabled:opacity-50`, `disabled:pointer-events-none`

### Transitions
- `transition-colors`, `transition-all`
- `duration-300`

## Troubleshooting

### Missing Styles?

1. **Check Tailwind is processing the gem files:**
   ```bash
   # In development, check if Tailwind is watching the gem
   npx tailwindcss --help | grep watch
   ```

2. **Force rebuild:**
   ```bash
   rails assets:clobber
   rails assets:precompile
   ```

3. **For production builds:**
   Ensure the gem paths are included before building:
   ```bash
   NODE_ENV=production rails assets:precompile
   ```

### Using JIT Mode

If using Tailwind's JIT mode, you might need to add the gem's components to your watch paths:

```javascript
// In development, ensure hot reload works with gem components
module.exports = {
  content: [
    './app/**/*.{erb,haml,html,slim,rb}',
    // Use require.resolve to find the gem path
    require.resolve('phlex-preline').replace(/[^\/]+$/, '') + '**/*.rb',
  ],
  // ... rest of config
}
```

## Rails-Specific Setup

### For Tailwind CSS Rails Gem

If using the `tailwindcss-rails` gem, update your `config/tailwind.config.js`:

```javascript
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/components/**/*.{rb,erb,haml,html,slim}',
    // Add this line for Phlex-Preline
    './vendor/bundle/**/gems/phlex-preline-*/app/components/**/*.rb',
  ],
  // ... rest of config
}
```

### For Webpacker

If using Webpacker with PostCSS:

```javascript
// postcss.config.js
module.exports = {
  plugins: [
    require('tailwindcss')('./app/javascript/stylesheets/tailwind.config.js'),
    require('autoprefixer'),
    require('postcss-import'),
    require('@tailwindcss/nesting'),
    require('postcss-flexbugs-fixes'),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    })
  ]
}
```

## Minimal CSS for File Upload Components

If you prefer not to use Tailwind's JIT/purge and want to include specific styles, add this to your application CSS:

```css
/* File Upload Specific Utilities */
@layer utilities {
  /* Sizes */
  .size-4 { width: 1rem; height: 1rem; }
  .size-10 { width: 2.5rem; height: 2.5rem; }
  .size-14 { width: 3.5rem; height: 3.5rem; }
  .size-20 { width: 5rem; height: 5rem; }
  .size-32 { width: 8rem; height: 8rem; }
  .size-40 { width: 10rem; height: 10rem; }
  
  /* Grid columns */
  .grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)); }
  .grid-cols-4 { grid-template-columns: repeat(4, minmax(0, 1fr)); }
  .grid-cols-5 { grid-template-columns: repeat(5, minmax(0, 1fr)); }
  .grid-cols-6 { grid-template-columns: repeat(6, minmax(0, 1fr)); }
  
  /* Height utilities */
  .h-1\.5 { height: 0.375rem; }
  
  /* Status colors */
  .border-green-200 { border-color: rgb(187 247 208); }
  .border-red-200 { border-color: rgb(254 202 202); }
  .bg-green-50 { background-color: rgb(240 253 244); }
  .bg-red-50 { background-color: rgb(254 242 242); }
  .bg-blue-100 { background-color: rgb(219 234 254); }
  .bg-blue-600 { background-color: rgb(37 99 235); }
  .text-green-600 { color: rgb(22 163 74); }
  .text-green-800 { color: rgb(22 101 52); }
  .text-red-600 { color: rgb(220 38 38); }
  .text-red-800 { color: rgb(153 27 27); }
  .text-blue-700 { color: rgb(29 78 216); }
  
  /* Interactive states */
  .hover\:bg-blue-200:hover { background-color: rgb(191 219 254); }
  .hover\:bg-red-50:hover { background-color: rgb(254 242 242); }
  .hover\:border-gray-400:hover { border-color: rgb(156 163 175); }
  .hover\:text-gray-500:hover { color: rgb(107 114 128); }
  
  /* Focus utilities */
  .focus\:ring-blue-500:focus { --tw-ring-color: rgb(59 130 246); }
  
  /* Other utilities */
  .border-dashed { border-style: dashed; }
  .min-w-0 { min-width: 0; }
  .flex-shrink-0 { flex-shrink: 0; }
  .grow { flex-grow: 1; }
  .shrink-0 { flex-shrink: 0; }
}
```