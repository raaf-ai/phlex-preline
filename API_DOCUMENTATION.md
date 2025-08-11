# Phlex-Preline API Documentation

## Version 0.2.0 Updates

This document provides comprehensive API documentation for the Phlex-Preline component library, including recent enhancements for Rails integration, HTTP method support, and standardized parameters.

## Table of Contents

1. [Button Component](#button-component)
2. [Input Component](#input-component)
3. [Badge Component](#badge-component)
4. [Migration Guide](#migration-guide)
5. [Rails Integration Patterns](#rails-integration-patterns)
6. [Best Practices](#best-practices)

---

## Button Component

The Button component provides a flexible, accessible button implementation with support for multiple variants, sizes, icons, and can render as either a button or link element.

### Basic Usage

```ruby
# Simple button
Button(text: "Click me")

# Button with variant and size
Button(text: "Save", variant: :success, size: :lg)

# Icon button
Button(text: "Settings", icon: "cog", icon_position: :left)
```

### Navigation Buttons (NEW)

Buttons now automatically detect when to render as anchor tags:

```ruby
# Auto-detects anchor tag from href
Button(text: "View Details", href: "/details")
# Renders: <a href="/details" class="hs-button">View Details</a>

# Explicit tag specification still supported
Button(text: "Home", tag: :a, href: "/")
```

### HTTP Method Support (NEW)

Enhanced Rails UJS integration for RESTful operations:

```ruby
# DELETE with automatic confirmation
Button(text: "Delete", href: "/items/1", method: :delete)
# Renders with data-method="delete" and data-confirm="Are you sure?"

# Custom confirmation message
Button(
  text: "Remove User", 
  href: "/users/1", 
  method: :delete,
  confirm: "This will permanently delete the user. Continue?"
)

# AJAX submission
Button(
  text: "Update", 
  href: "/items/1", 
  method: :patch,
  remote: true
)

# POST method
Button(text: "Create", href: "/items", method: :post)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | String | required* | Button text (*not required if icon provided) |
| `variant` | Symbol | `:primary` | Visual style: `:primary`, `:secondary`, `:success`, `:danger`, `:warning`, `:info`, `:link`, `:outline`, `:ghost` |
| `size` | Symbol | `:md` | Size: `:xs`, `:sm`, `:md`, `:lg`, `:xl` |
| `href` | String | `nil` | URL for navigation (auto-detects anchor tag) |
| `method` | Symbol | `nil` | HTTP method: `:get`, `:post`, `:put`, `:patch`, `:delete` |
| `confirm` | String | `nil` | Confirmation message (auto-added for `:delete`) |
| `remote` | Boolean | `false` | Enable AJAX submission via Rails UJS |
| `icon` | String | `nil` | Font Awesome icon name |
| `icon_position` | Symbol | `:left` | Icon position: `:left` or `:right` |
| `disabled` | Boolean | `false` | Disable the button |
| `loading` | Boolean | `false` | Show loading spinner |
| `full_width` | Boolean | `false` | Make button full width |
| `type` | Symbol | `:button` | Button type: `:button`, `:submit`, `:reset` |
| `tag` | Symbol | auto | HTML tag: `:button` or `:a` (auto-detected from href) |
| `class` | String | `nil` | Additional CSS classes |
| `data` | Hash | `{}` | Data attributes |

### Size Parameter Migration

The component now supports both legacy and modern size names with deprecation warnings:

```ruby
# Modern (recommended)
Button(text: "Small", size: :sm)
Button(text: "Large", size: :lg)

# Legacy (deprecated - will show warning)
Button(text: "Small", size: :small)  # Deprecated: Use :sm
Button(text: "Large", size: :large)  # Deprecated: Use :lg
```

### Examples

#### Loading State Button
```ruby
Button(
  text: "Processing...",
  loading: true,
  disabled: true
)
```

#### Icon-Only Button
```ruby
Button(
  icon: "trash",
  variant: :danger,
  aria_label: "Delete item"
)
```

#### Full-Width Submit Button
```ruby
Button(
  text: "Submit Form",
  type: :submit,
  variant: :primary,
  full_width: true
)
```

---

## Input Component

The Input component provides form field functionality with Rails form builder integration and model-aware capabilities.

### Basic Usage

```ruby
# With Rails form builder
form_with(model: @user) do |f|
  Input(form: f, field: :email, type: :email, label: "Email Address")
end

# Standalone with model (NEW)
Input(
  model: @user,
  field: :email,
  type: :email,
  label: "Email Address"
)

# Simple standalone
Input(
  field: :search,
  placeholder: "Search...",
  type: :search
)
```

### Model-Aware Features (NEW)

The Input component can now bind directly to models without form builders:

```ruby
# Automatic value binding from model
Input(
  model: @user,
  field: :name,
  label: "Full Name"
)
# Automatically gets value from @user.name

# Automatic error display from model
Input(
  model: @user,
  field: :email,
  label: "Email"
)
# Automatically shows @user.errors[:email] if present

# With custom value override
Input(
  model: @user,
  field: :name,
  value: "Custom Value",
  label: "Name"
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `field` | Symbol | required | Field name or model attribute |
| `form` | FormBuilder | `nil` | Rails form builder instance |
| `model` | ActiveRecord | `nil` | Model instance for value/error binding |
| `type` | Symbol | `:text` | Input type: `:text`, `:password`, `:email`, `:number`, `:tel`, `:url`, `:search`, `:date`, `:textarea`, etc. |
| `label` | String | `nil` | Field label text |
| `value` | String | `nil` | Field value (auto-populated from model if provided) |
| `placeholder` | String | `nil` | Placeholder text |
| `help_text` | String | `nil` | Help text below input |
| `required` | Boolean | `false` | Mark as required field |
| `disabled` | Boolean | `false` | Disable the input |
| `readonly` | Boolean | `false` | Make input read-only |
| `error` | String | `nil` | Error message (auto-populated from model if provided) |
| `input_class` | String | `''` | Additional CSS classes for input element |
| `wrapper_class` | String | `''` | Additional CSS classes for wrapper |

### Form Integration Examples

#### With Rails Form Builder
```ruby
form_with(model: @product) do |f|
  Input(
    form: f,
    field: :name,
    label: "Product Name",
    required: true,
    help_text: "Enter the product display name"
  )
  
  Input(
    form: f,
    field: :description,
    type: :textarea,
    label: "Description",
    placeholder: "Describe your product..."
  )
end
```

#### Model-Aware Without Form Builder
```ruby
# In a Phlex component
div(class: "form-container") do
  Input(
    model: @user,
    field: :email,
    type: :email,
    label: "Email Address",
    required: true
  )
  
  Input(
    model: @user,
    field: :password,
    type: :password,
    label: "Password",
    help_text: "Must be at least 8 characters"
  )
  
  Button(text: "Save", type: :submit)
end
```

---

## Badge Component

The Badge component displays labels, statuses, and counts with various visual styles.

### Basic Usage

```ruby
# Simple badge
Badge(text: "New")

# Badge with variant
Badge(text: "Active", variant: :success)

# Badge with icon
Badge(text: "Verified", variant: :info, icon: "check")
```

### Size Standardization (NEW)

Badges now support standardized size parameters:

```ruby
# Modern sizes (recommended)
Badge(text: "Extra Small", size: :xs)
Badge(text: "Small", size: :sm)
Badge(text: "Medium", size: :md)
Badge(text: "Large", size: :lg)

# Legacy sizes (deprecated)
Badge(text: "Small", size: :small)  # Shows deprecation warning
Badge(text: "Large", size: :large)  # Shows deprecation warning
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | String | required | Badge text content |
| `variant` | Symbol | `:primary` | Color variant: `:primary`, `:secondary`, `:success`, `:danger`, `:warning`, `:info`, `:light`, `:dark`, `:gray` |
| `size` | Symbol | `:md` | Size: `:xs`, `:sm`, `:md`, `:lg` |
| `icon` | String | `nil` | Font Awesome icon name |
| `removable` | Boolean | `false` | Show remove button |
| `pill` | Boolean | `false` | Use pill style (rounded) |
| `outline` | Boolean | `false` | Use outline style |
| `class` | String | `nil` | Additional CSS classes |

### Examples

```ruby
# Status badges
Badge(text: "Active", variant: :success, pill: true)
Badge(text: "Pending", variant: :warning)
Badge(text: "Archived", variant: :gray, outline: true)

# Removable tags
Badge(
  text: "Ruby",
  removable: true,
  variant: :info,
  data: { controller: "removable-badge" }
)

# Icon badges
Badge(
  text: "Premium",
  icon: "star",
  variant: :warning,
  size: :lg
)
```

---

## Migration Guide

### Migrating from Legacy Patterns

#### Button Navigation

**Old Pattern:**
```ruby
# Required explicit tag specification
Button(text: "View", tag: :a, href: "/view")
```

**New Pattern:**
```ruby
# Auto-detects anchor tag
Button(text: "View", href: "/view")
```

#### Size Parameters

**Old Pattern:**
```ruby
Button(text: "Large Button", size: :large)
Badge(text: "Small Badge", size: :small)
```

**New Pattern:**
```ruby
Button(text: "Large Button", size: :lg)
Badge(text: "Small Badge", size: :sm)
```

#### HTTP Methods

**Old Pattern:**
```ruby
# Manual Rails button_to helper
button_to "Delete", item_path(@item), method: :delete, 
          data: { confirm: "Are you sure?" }
```

**New Pattern:**
```ruby
# Preline Button with Rails UJS
Button(
  text: "Delete",
  href: item_path(@item),
  method: :delete,
  confirm: "Are you sure?"
)
```

#### Form Inputs

**Old Pattern:**
```ruby
# Mixed Rails helpers and Preline components
form_with(model: @user) do |f|
  f.text_field :email, class: "form-input"
  render Input.new(name: "user[name]", value: @user.name)
end
```

**New Pattern:**
```ruby
# Consistent Preline components
form_with(model: @user) do |f|
  Input(form: f, field: :email, label: "Email")
  Input(form: f, field: :name, label: "Name")
end

# Or model-aware without form builder
Input(model: @user, field: :email, label: "Email")
Input(model: @user, field: :name, label: "Name")
```

### Deprecation Timeline

- **Version 0.2.0** (Current): Deprecation warnings added
- **Version 0.3.0**: Warnings continue, migration tools provided
- **Version 1.0.0**: Legacy patterns removed

### Handling Deprecation Warnings

Deprecation warnings appear in development and test environments:

```
[DEPRECATION] Size 'large' is deprecated. Use 'lg' instead. This will be removed in version 1.0.0.
[DEPRECATION] `additional_classes` is deprecated. Use `class` instead. This will be removed in version 1.0.0.
```

To suppress warnings temporarily (not recommended):
```ruby
# In config/initializers/phlex_preline.rb
ActiveSupport::Deprecation.silenced = true
```

---

## Rails Integration Patterns

### RESTful Navigation

Use Preline buttons for RESTful operations with proper HTTP methods:

```ruby
# Index/List view
Button(text: "New Item", href: new_item_path, icon: "plus")

# Show view actions
div(class: "actions") do
  Button(text: "Edit", href: edit_item_path(@item), variant: :primary)
  Button(
    text: "Delete", 
    href: item_path(@item), 
    method: :delete,
    variant: :danger,
    confirm: "This action cannot be undone. Continue?"
  )
end

# Form submissions
Button(
  text: "Update",
  href: item_path(@item),
  method: :patch,
  remote: true
)
```

### Form Patterns

#### Pattern 1: Rails Form Builder
Best for traditional Rails forms with CSRF protection and remote options:

```ruby
form_with(model: @user, local: false) do |f|
  Input(form: f, field: :email, type: :email, label: "Email")
  Input(form: f, field: :password, type: :password, label: "Password")
  
  Button(text: "Sign In", type: :submit, variant: :primary)
end
```

#### Pattern 2: Model-Aware Components
Best for Phlex-based forms without Rails form helpers:

```ruby
div(data: { controller: "user-form" }) do
  Input(model: @user, field: :email, type: :email, label: "Email")
  Input(model: @user, field: :password, type: :password, label: "Password")
  
  Button(
    text: "Save",
    href: user_path(@user),
    method: :patch,
    remote: true
  )
end
```

#### Pattern 3: Standalone Components
Best for search forms and filters:

```ruby
div(class: "search-bar") do
  Input(
    field: :query,
    type: :search,
    placeholder: "Search products...",
    input_class: "search-input"
  )
  
  Button(text: "Search", icon: "search", variant: :primary)
end
```

---

## Best Practices

### Accessibility

1. **Always provide text or aria-label for buttons:**
```ruby
# Good - text provided
Button(text: "Save", icon: "save")

# Good - aria-label for icon-only
Button(icon: "settings", aria_label: "Open settings")

# Bad - no accessible text
Button(icon: "trash")  # Missing aria_label
```

2. **Mark required fields:**
```ruby
Input(
  model: @user,
  field: :email,
  label: "Email",
  required: true  # Adds visual indicator and aria-required
)
```

3. **Associate errors with inputs:**
```ruby
# Automatically handled by the component
Input(
  model: @user,
  field: :email,
  error: @user.errors[:email].first
)
# Adds aria-invalid="true" and aria-describedby
```

### Performance

1. **Use appropriate loading states:**
```ruby
# Show loading state during async operations
Button(
  text: "Processing...",
  loading: true,
  disabled: true
)
```

2. **Batch form updates:**
```ruby
# Good - single form submission
form_with(model: @user) do |f|
  # Multiple inputs in one form
  Input(form: f, field: :name)
  Input(form: f, field: :email)
  Button(type: :submit)
end

# Avoid - multiple individual updates
Button(text: "Update Name", href: "/update_name", method: :patch)
Button(text: "Update Email", href: "/update_email", method: :patch)
```

### Security

1. **Use Rails UJS for state-changing operations:**
```ruby
# Good - proper HTTP method
Button(text: "Delete", href: item_path(@item), method: :delete)

# Bad - GET request for deletion
Button(text: "Delete", href: "/items/1/delete")  # Vulnerable to CSRF
```

2. **Always confirm destructive actions:**
```ruby
Button(
  text: "Delete Account",
  href: account_path,
  method: :delete,
  confirm: "This will permanently delete your account. Are you sure?",
  variant: :danger
)
```

### Consistency

1. **Use semantic variants:**
```ruby
# Good - semantic meaning
Badge(text: "Active", variant: :success)
Badge(text: "Archived", variant: :gray)
Button(text: "Delete", variant: :danger)

# Avoid - color-based variants
Badge(text: "Active", variant: :green)  # Use :success
Button(text: "Delete", variant: :red)   # Use :danger
```

2. **Standardize sizes across components:**
```ruby
# Consistent sizing
Button(text: "Large", size: :lg)
Badge(text: "Large", size: :lg)
Input(field: :name, input_class: "text-lg")
```

---

## Component Combinations

### Action Bars
```ruby
div(class: "action-bar flex gap-2") do
  Button(text: "New", href: new_item_path, variant: :primary, icon: "plus")
  Button(text: "Export", href: export_items_path, variant: :outline, icon: "download")
  Button(text: "Filter", variant: :ghost, icon: "filter")
end
```

### Form with Validation
```ruby
form_with(model: @product) do |f|
  # Name field with error
  Input(
    form: f,
    field: :name,
    label: "Product Name",
    required: true,
    error: @product.errors[:name].first,
    help_text: "Choose a unique product name"
  )
  
  # Price field
  Input(
    form: f,
    field: :price,
    type: :number,
    label: "Price",
    placeholder: "0.00",
    help_text: "Enter price in USD"
  )
  
  # Status badge
  div(class: "mt-4") do
    span(class: "mr-2") { "Status:" }
    Badge(
      text: @product.status,
      variant: @product.active? ? :success : :gray
    )
  end
  
  # Form actions
  div(class: "mt-6 flex gap-2") do
    Button(text: "Save", type: :submit, variant: :primary)
    Button(text: "Cancel", href: products_path, variant: :outline)
  end
end
```

### Data Table Actions
```ruby
tr do
  td { @user.name }
  td { @user.email }
  td do
    Badge(text: @user.role, variant: :info, size: :sm)
  end
  td(class: "actions") do
    Button(text: "Edit", href: edit_user_path(@user), size: :sm)
    Button(
      text: "Remove",
      href: user_path(@user),
      method: :delete,
      size: :sm,
      variant: :danger,
      confirm: "Remove this user?"
    )
  end
end
```

---

## Troubleshooting

### Common Issues

**Issue: Button doesn't navigate when href is provided**
- Ensure you're using the latest version (0.2.0+)
- Check that the href is a valid URL or path
- Verify no JavaScript is preventing default behavior

**Issue: Deprecation warnings in production**
- Update to use modern parameter names
- Deprecation warnings only show in development/test by default
- See Migration Guide for updating legacy code

**Issue: Model errors not showing in Input**
- Ensure model has been validated (`@model.valid?`)
- Check that errors are present on the model
- Verify field name matches model attribute

**Issue: Rails UJS methods not working**
- Ensure Rails UJS is loaded in your application
- Check that `rails-ujs` or `@rails/ujs` is in your JavaScript pipeline
- Verify the method is a valid HTTP verb

---

## Version History

### v0.2.0 (Current)
- Auto-detection of anchor tags for buttons with href
- Enhanced Rails UJS support for HTTP methods
- Standardized size parameters with deprecation warnings
- Model-aware input components
- Improved documentation and examples

### v0.1.x
- Initial component library
- Basic Rails integration
- Form builder support

---

## Contributing

To contribute to Phlex-Preline:

1. Follow the established patterns in this documentation
2. Add tests for new functionality
3. Update documentation for API changes
4. Ensure backward compatibility or add deprecation warnings
5. Run the test suite: `bundle exec rspec`

For more information, see the [GitHub repository](https://github.com/your-org/phlex-preline).