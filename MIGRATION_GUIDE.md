# Phlex-Preline Migration Guide

## Migrating to v0.2.0

This guide helps you migrate your existing Phlex-Preline code to version 0.2.0, which introduces standardized APIs, enhanced Rails integration, and deprecates some legacy patterns.

## Quick Migration Checklist

- [ ] Update button components with `href` to remove explicit `tag: :a`
- [ ] Replace legacy size parameters (`small`, `large`) with modern ones (`sm`, `lg`)
- [ ] Update `additional_classes` to `class` parameter
- [ ] Review form inputs for model-aware opportunities
- [ ] Test Rails UJS functionality for HTTP methods
- [ ] Run tests and address deprecation warnings

## Component-by-Component Migration

### Button Component

#### Navigation Buttons

**Before:**
```ruby
# Had to explicitly specify tag: :a
Button(text: "View Profile", tag: :a, href: "/profile")
Button(text: "Dashboard", tag: :a, href: dashboard_path)

# Mixing Rails link_to with Preline styling
link_to "Edit", edit_item_path(@item), class: "hs-button hs-button-primary"
```

**After:**
```ruby
# Automatically detects anchor tag from href
Button(text: "View Profile", href: "/profile")
Button(text: "Dashboard", href: dashboard_path)

# Use Preline Button directly
Button(text: "Edit", href: edit_item_path(@item), variant: :primary)
```

#### RESTful Actions

**Before:**
```ruby
# Using Rails button_to helper
button_to "Delete", item_path(@item), 
  method: :delete,
  class: "hs-button hs-button-danger",
  data: { confirm: "Are you sure?" }

# Manual form for PATCH/PUT
form_tag item_path(@item), method: :patch do
  submit_tag "Update", class: "hs-button"
end
```

**After:**
```ruby
# Preline Button with Rails UJS
Button(
  text: "Delete",
  href: item_path(@item),
  method: :delete,
  variant: :danger,
  confirm: "Are you sure?"
)

# Direct PATCH/PUT support
Button(
  text: "Update",
  href: item_path(@item),
  method: :patch
)
```

#### Size Parameters

**Before:**
```ruby
Button(text: "Small", size: :small)
Button(text: "Large", size: :large)
Button(text: "Extra Large", size: "extra-large")
```

**After:**
```ruby
Button(text: "Small", size: :sm)
Button(text: "Large", size: :lg)
Button(text: "Extra Large", size: :xl)
```

### Input Component

#### Form Builder Integration

**Before:**
```ruby
# Mixed Rails helpers and Preline components
form_with(model: @user) do |f|
  # Some inputs use Rails helpers
  f.text_field :name, class: "hs-input"
  
  # Others use Preline without proper binding
  render Input.new(
    field: :email,
    name: "user[email]",
    value: @user.email,
    label: "Email"
  )
end
```

**After:**
```ruby
# Consistent Preline components with form builder
form_with(model: @user) do |f|
  Input(form: f, field: :name, label: "Name")
  Input(form: f, field: :email, type: :email, label: "Email")
end
```

#### Model-Aware Inputs (New Feature)

**Before:**
```ruby
# Manual value and error binding
div do
  label { "Email" }
  input(
    type: "email",
    name: "user[email]",
    value: @user.email,
    class: @user.errors[:email].any? ? "input-error" : "input"
  )
  if @user.errors[:email].any?
    span(class: "error") { @user.errors[:email].first }
  end
end
```

**After:**
```ruby
# Automatic model binding
Input(
  model: @user,
  field: :email,
  type: :email,
  label: "Email"
)
# Automatically handles value, name, and error display
```

### Badge Component

#### Size Standardization

**Before:**
```ruby
Badge(text: "New", size: :small)
Badge(text: "Featured", size: :large)
Badge(text: "Beta", size: "extra-small")
```

**After:**
```ruby
Badge(text: "New", size: :sm)
Badge(text: "Featured", size: :lg)
Badge(text: "Beta", size: :xs)
```

### Common Parameter Changes

#### Class Parameter

**Before:**
```ruby
Button(text: "Save", additional_classes: "custom-btn mt-4")
Badge(text: "New", additional_classes: "animate-pulse")
Input(field: :name, additional_classes: "rounded-lg")
```

**After:**
```ruby
Button(text: "Save", class: "custom-btn mt-4")
Badge(text: "New", class: "animate-pulse")
Input(field: :name, class: "rounded-lg")
```

## Automated Migration Script

You can use this Ruby script to help migrate your codebase:

```ruby
#!/usr/bin/env ruby
# save as: migrate_phlex_preline.rb

require 'fileutils'

class PhlexPrelineMigrator
  REPLACEMENTS = {
    # Size parameters
    'size: :small' => 'size: :sm',
    'size: :large' => 'size: :lg',
    'size: "small"' => 'size: :sm',
    'size: "large"' => 'size: :lg',
    'size: "extra-small"' => 'size: :xs',
    'size: "extra-large"' => 'size: :xl',
    
    # Class parameters
    'additional_classes:' => 'class:',
    
    # Button tag specification (remove when href present)
    /Button\([^)]*tag:\s*:a,\s*([^)]*href:[^)]*)\)/ => 'Button(\1)',
  }
  
  def self.migrate_file(filepath)
    content = File.read(filepath)
    original = content.dup
    
    REPLACEMENTS.each do |pattern, replacement|
      if pattern.is_a?(Regexp)
        content.gsub!(pattern, replacement)
      else
        content.gsub!(pattern, replacement)
      end
    end
    
    if content != original
      File.write(filepath, content)
      puts "✓ Migrated: #{filepath}"
      true
    else
      false
    end
  end
  
  def self.run(directory = '.')
    migrated = 0
    
    Dir.glob("#{directory}/**/*.rb").each do |file|
      migrated += 1 if migrate_file(file)
    end
    
    Dir.glob("#{directory}/**/*.erb").each do |file|
      migrated += 1 if migrate_file(file)
    end
    
    puts "\n#{migrated} files migrated successfully."
  end
end

# Run the migration
if ARGV[0]
  PhlexPrelineMigrator.run(ARGV[0])
else
  puts "Usage: ruby migrate_phlex_preline.rb <directory>"
  puts "Example: ruby migrate_phlex_preline.rb app/views"
end
```

## Handling Deprecation Warnings

### Understanding Warnings

When you run your application in development or test environment, you'll see warnings like:

```
[DEPRECATION] Size 'small' is deprecated. Use 'sm' instead. This will be removed in version 1.0.0.
[DEPRECATION] `additional_classes` is deprecated. Use `class` instead. This will be removed in version 1.0.0.
```

### Finding Deprecated Usage

Use grep to find deprecated patterns in your codebase:

```bash
# Find legacy size parameters
grep -r "size: :small\|size: :large" app/
grep -r 'size: "small"\|size: "large"' app/

# Find additional_classes usage
grep -r "additional_classes:" app/

# Find explicit tag: :a with href
grep -r "tag: :a.*href:\|href:.*tag: :a" app/
```

### Gradual Migration Strategy

1. **Phase 1: Update Critical Paths** (Week 1)
   - User-facing forms and buttons
   - Primary navigation elements
   - High-traffic pages

2. **Phase 2: Update Secondary Features** (Week 2)
   - Admin interfaces
   - Settings pages
   - Less-used components

3. **Phase 3: Update Tests and Documentation** (Week 3)
   - Update test fixtures
   - Update documentation examples
   - Update style guides

## Rails-Specific Migrations

### Replacing button_to with Preline Button

**Before:**
```ruby
<%= button_to "Delete", item_path(@item), 
    method: :delete,
    data: { confirm: "Are you sure?" },
    class: "btn btn-danger" %>
```

**After (in Phlex component):**
```ruby
Button(
  text: "Delete",
  href: item_path(@item),
  method: :delete,
  confirm: "Are you sure?",
  variant: :danger
)
```

### Replacing link_to with Preline Button

**Before:**
```ruby
<%= link_to "Edit", edit_item_path(@item), 
    class: "btn btn-primary" %>
```

**After (in Phlex component):**
```ruby
Button(
  text: "Edit",
  href: edit_item_path(@item),
  variant: :primary
)
```

### Form Helper Migration

**Before (ERB):**
```erb
<%= form_with model: @user do |f| %>
  <div class="form-group">
    <%= f.label :email %>
    <%= f.email_field :email, class: "form-control" %>
    <% if @user.errors[:email].any? %>
      <span class="error"><%= @user.errors[:email].first %></span>
    <% end %>
  </div>
<% end %>
```

**After (Phlex):**
```ruby
form_with(model: @user) do |f|
  Input(
    form: f,
    field: :email,
    type: :email,
    label: "Email",
    error: @user.errors[:email].first
  )
end
```

## Testing Your Migration

### 1. Run Your Test Suite

```bash
bundle exec rspec
```

Look for deprecation warnings in test output.

### 2. Check for Visual Regressions

After migration, verify that:
- Buttons still navigate correctly
- Forms submit properly
- Styles appear consistent
- HTTP methods work as expected

### 3. Test Rails UJS Features

Ensure these features work:
- DELETE confirmations appear
- PATCH/PUT methods submit correctly
- Remote forms work via AJAX
- CSRF tokens are included

### Example Test Updates

**Before:**
```ruby
it "renders a link button" do
  button = Button.new(text: "Link", tag: :a, href: "/path")
  expect(button.to_html).to include('<a')
end

it "uses large size" do
  button = Button.new(text: "Big", size: :large)
  expect(button.to_html).to include('hs-button-large')
end
```

**After:**
```ruby
it "auto-renders as link with href" do
  button = Button.new(text: "Link", href: "/path")
  expect(button.to_html).to include('<a')
end

it "uses large size" do
  button = Button.new(text: "Big", size: :lg)
  expect(button.to_html).to include('hs-button-lg')
end
```

## Rollback Plan

If you encounter issues after upgrading:

1. **Pin to previous version** in Gemfile:
```ruby
gem 'phlex-preline', '~> 0.1.0'
```

2. **Run bundle update:**
```bash
bundle update phlex-preline
```

3. **Report issues** on GitHub with:
   - Error messages
   - Code examples
   - Expected vs actual behavior

## Getting Help

- **Documentation:** See API_DOCUMENTATION.md
- **Examples:** Check USAGE_GUIDE.md
- **Issues:** Report on GitHub
- **Deprecation Timeline:** v1.0.0 will remove deprecated features

## Timeline

- **v0.2.0** (Current): Deprecation warnings introduced
- **v0.3.0** (Q2 2024): Migration tools and helpers
- **v1.0.0** (Q3 2024): Deprecated features removed

Plan your migration accordingly to avoid breaking changes in v1.0.0.