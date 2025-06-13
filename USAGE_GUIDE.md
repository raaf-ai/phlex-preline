# Phlex-Preline Components Usage Guide

This guide helps you use the Phlex-Preline UI components effectively in your Rails application.

## Using Components via Kit

Phlex-Preline components are available through a Phlex Kit, which allows you to use component names directly. Instead of `Components::Preline::Button(...)`, you can simply use `Button(...)` with the component's arguments.

## Component Patterns

Phlex-Preline components support two equally valid patterns:

### 1. Yielding Interface Pattern
Provides a structured API with helpful methods:

```ruby
Breadcrumb do |breadcrumb|
  breadcrumb.home
  breadcrumb.item(text: "Products", href: "/products")
  breadcrumb.item(text: "Electronics", href: "/products/electronics")
  breadcrumb.item(text: "Laptop")
end
```

### 2. Direct Content Pattern
Simple and direct for basic content:

```ruby
Modal(id: "my-modal") do
  h3 { "Modal Title" }
  p { "Modal content goes here" }
end
```

## Component Reference

### Navigation Components

#### Breadcrumb
Shows hierarchical navigation path.

```ruby
# Basic usage
Breadcrumb do |breadcrumb|
  breadcrumb.home
  breadcrumb.item(text: "Category", href: "/category")
  breadcrumb.item(text: "Current Page")
end

# With custom classes on items
Breadcrumb do |breadcrumb|
  breadcrumb.home(class: "font-semibold")
  breadcrumb.item(text: "Products", href: "/products", class: "text-blue-600")
  breadcrumb.item(text: "Current", class: "text-gray-500")
end

# Auto-generate from URL path
Breadcrumb do |breadcrumb|
  breadcrumb.from_path(request.path, labels: {
    "products" => "All Products",
    "electronics" => "Electronics & Gadgets"
  })
end

# With custom styling
Breadcrumb(
  separator: :chevron,
  class: "text-sm",
  item_class: "hover:text-blue-600"
) do |breadcrumb|
  # items...
end
```

#### Navbar
Main navigation bar component.

```ruby
Navbar(
  brand: { text: "My App", href: "/" },
  sticky: true
) do |navbar|
  navbar.nav_item(text: "Home", href: "/", active: true)
  navbar.nav_item(text: "Features", href: "/features")
  navbar.dropdown(text: "Products") do |dropdown|
    dropdown.item(text: "All Products", href: "/products")
    dropdown.item(text: "Categories", href: "/categories")
  end
end
```

#### Sidebar
Side navigation panel.

```ruby
Sidebar do |sidebar|
  sidebar.section(title: "Main") do |section|
    section.item(text: "Dashboard", href: "/dashboard", icon: "home")
    section.item(text: "Analytics", href: "/analytics", icon: "chart-bar")
  end
  
  sidebar.section(title: "Settings") do |section|
    section.item(text: "Profile", href: "/profile", icon: "user")
    section.item(text: "Preferences", href: "/preferences", icon: "cog")
  end
end
```

### Action Components

#### Button & ButtonGroup
Individual buttons and button groups.

```ruby
# Single button
Button(
  text: "Save Changes",
  variant: :primary,
  icon: "save",
  type: "submit"
)

# Button group
ButtonGroup(size: :sm) do |group|
  group.button(text: "Edit", icon: "edit", variant: :secondary)
  group.button(text: "Delete", icon: "trash", variant: :danger)
end

# Convenience methods
ButtonGroup do |group|
  group.save_cancel  # Adds Save and Cancel buttons
  group.crud_actions(actions: [:create, :read, :update, :delete])
end
```

#### Dropdown
Contextual overlay menus.

```ruby
# Basic dropdown
Dropdown(
  trigger_text: "Options",
  trigger_icon: "cog"
) do |dropdown|
  dropdown.item(text: "Edit", href: "/edit", icon: "edit")
  dropdown.item(text: "Duplicate", icon: "copy")
  dropdown.divider
  dropdown.item(text: "Delete", icon: "trash", variant: :danger)
end

# User menu dropdown
Dropdown(
  trigger_text: current_user.name,
  trigger_icon: "user-circle",
  placement: :"bottom-end"
) do |dropdown|
  dropdown.header(text: current_user.email)
  dropdown.divider
  dropdown.item(text: "Profile", href: "/profile", icon: "user")
  dropdown.item(text: "Settings", href: "/settings", icon: "cog")
  dropdown.divider
  dropdown.item(text: "Sign out", href: "/logout", icon: "sign-out-alt")
end

# With custom classes
Dropdown(trigger_text: "Actions") do |dropdown|
  dropdown.header(text: "Quick Actions", class: "font-bold text-lg")
  dropdown.divider(class: "my-2")
  dropdown.item(text: "Edit", icon: "edit", class: "hover:bg-blue-50")
  dropdown.item(text: "Delete", icon: "trash", class: "text-red-600 hover:bg-red-50")
end
```

### Layout Components

#### Card
Content container with optional header/footer.

```ruby
Card do |card|
  card.header do
    h3 { "Card Title" }
  end
  
  card.body do
    p { "Card content goes here" }
  end
  
  card.footer do
    Button(text: "Learn More", variant: :primary)
  end
end
```

#### Modal
Overlay dialog component.

```ruby
Modal(id: "edit-modal", size: :lg) do |modal|
  modal.header(title: "Edit Item", close_button: true)
  
  modal.body do
    # Form content
  end
  
  modal.footer do
    Button(text: "Cancel", variant: :secondary, data: { bs_dismiss: "modal" })
    Button(text: "Save Changes", variant: :primary)
  end
end

# Trigger button
Button(text: "Open Modal", data: { bs_toggle: "modal", bs_target: "#edit-modal" })
```

#### Offcanvas
Slide-out panel from screen edges.

```ruby
Offcanvas(
  id: "settings-panel",
  position: :right,
  size: :lg
) do |offcanvas|
  offcanvas.header(title: "Settings")
  
  offcanvas.body do |o|
    o.navigation(
      title: "Preferences",
      items: [
        { text: "General", href: "#general", icon: "cog" },
        { text: "Security", href: "#security", icon: "shield-alt" },
        { text: "Privacy", href: "#privacy", icon: "lock" }
      ]
    )
  end
  
  offcanvas.footer do
    Button(text: "Save Settings", variant: :primary, class: "w-full")
  end
end
```

### Data Display Components

#### Table
Data table with sorting and actions.

```ruby
Table(
  striped: true,
  hoverable: true
) do |table|
  table.header do |header|
    header.row do |row|
      row.cell("Name", sortable: true)
      row.cell("Email", sortable: true)
      row.cell("Status")
      row.cell("Actions", class: "text-right")
    end
  end
  
  table.body do |body|
    users.each do |user|
      body.row do |row|
        row.cell(user.name)
        row.cell(user.email)
        row.cell do
          Badge(text: user.status, variant: user.active? ? :success : :secondary)
        end
        row.cell(class: "text-right") do
          ButtonGroup(size: :sm) do |group|
            group.button(text: "Edit", icon: "edit")
            group.button(text: "Delete", icon: "trash", variant: :danger)
          end
        end
      end
    end
  end
end
```

#### List & ListGroup
Organized list displays.

```ruby
ListGroup do |list|
  list.item(active: true) do
    h5 { "Active Item" }
    p(class: "text-sm text-gray-600") { "This item is currently selected" }
  end
  
  list.item(href: "/item-2") do
    h5 { "Clickable Item" }
    p(class: "text-sm text-gray-600") { "Click to navigate" }
  end
  
  list.item(disabled: true) do
    h5 { "Disabled Item" }
    p(class: "text-sm text-gray-600") { "This item is disabled" }
  end
end
```

### Form Components

#### Form
Form container with built-in structure.

```ruby
Form(
  action: "/users",
  method: :post
) do |form|
  form.group do
    form.label(for: "email", text: "Email Address")
    form.input(type: "email", id: "email", name: "user[email]", required: true)
    form.helper_text("We'll never share your email")
  end
  
  form.group do
    form.label(for: "password", text: "Password")
    form.input(type: "password", id: "password", name: "user[password]")
  end
  
  form.actions do
    Button(text: "Submit", type: "submit", variant: :primary)
  end
end
```

#### Input Components
Various input types with consistent styling.

```ruby
# Text input with icon
Input(
  type: "text",
  placeholder: "Search...",
  icon: "search",
  name: "q"
)

# Input group
InputGroup do |group|
  group.prepend { "$" }
  group.input(type: "number", placeholder: "0.00", name: "amount")
  group.append { "USD" }
end

# Select dropdown
Select(
  name: "country",
  options: {
    "us" => "United States",
    "ca" => "Canada",
    "uk" => "United Kingdom"
  },
  selected: "us"
)
```

### Feedback Components

#### Alert
Informational messages.

```ruby
Alert(
  type: :success,
  title: "Success!",
  dismissible: true
) do
  "Your changes have been saved successfully."
end

# With list of messages
Alert(
  type: :error,
  title: "Please fix the following errors:",
  messages: user.errors.full_messages
)
```

#### Toast
Temporary notification messages.

```ruby
Toast(
  title: "Notification",
  message: "Your file has been uploaded",
  type: :success,
  autohide: true,
  delay: 5000
)
```

#### Modal Dialogs
Pre-configured modal patterns.

```ruby
# Confirmation dialog
Modal(id: "confirm-delete") do |modal|
  modal.header(title: "Confirm Deletion")
  modal.body do
    p { "Are you sure you want to delete this item? This action cannot be undone." }
  end
  modal.footer do
    Button(text: "Cancel", variant: :secondary, data: { bs_dismiss: "modal" })
    Button(
      text: "Delete", 
      variant: :danger,
      data: { 
        turbo_method: :delete,
        turbo_href: delete_item_path
      }
    )
  end
end
```

### Advanced Components

#### Tabs
Tabbed interface for content organization.

```ruby
Tabs do |tabs|
  tabs.tab(id: "overview", label: "Overview", active: true) do
    # Overview content
  end
  
  tabs.tab(id: "details", label: "Details") do
    # Details content
  end
  
  tabs.tab(id: "history", label: "History", badge: "5") do
    # History content
  end
end
```

#### Accordion
Collapsible content panels.

```ruby
Accordion(multiple: true) do |accordion|
  accordion.item(title: "Section 1", open: true) do
    "Content for section 1"
  end
  
  accordion.item(title: "Section 2") do
    "Content for section 2"
  end
  
  accordion.item(title: "Section 3") do
    "Content for section 3"
  end
end
```

#### Stepper
Multi-step process indicator.

```ruby
Stepper(current: 2) do |stepper|
  stepper.step(title: "Account Info", description: "Provide your details")
  stepper.step(title: "Verification", description: "Verify your email", active: true)
  stepper.step(title: "Confirmation", description: "Review and confirm")
end
```

## Best Practices

### 1. Choose the Right Pattern
- Use **yielding interface** for complex components that benefit from structured APIs
- Use **direct content** for simple components or custom layouts

### 2. Accessibility
- Always include proper ARIA labels for interactive elements
- Use semantic HTML elements (the components handle this for you)
- Provide alt text for images and icons

### 3. Responsive Design
- Components are mobile-first and responsive by default
- Use size variants appropriately (`:sm`, `:md`, `:lg`)
- Test on different screen sizes

### 4. Performance
- Components are optimized for performance
- Use Turbo/Stimulus for dynamic interactions
- Lazy load heavy components when possible

### 5. Styling
- Components use Tailwind CSS classes
- Override with custom classes when needed
- Use theme-aware styling for dark mode support

### 6. Data Attributes
- Use `data` attributes for JavaScript interactions
- Components support Stimulus and Alpine.js out of the box
- Follow Rails UJS conventions for actions

## Common Patterns

### Loading States
```ruby
Button(
  text: is_loading ? "Loading..." : "Submit",
  disabled: is_loading,
  icon: is_loading ? "spinner" : "check",
  icon_class: is_loading ? "animate-spin" : ""
)
```

### Conditional Rendering
```ruby
Alert(type: :info) do
  if user.subscription.expiring?
    "Your subscription expires in #{user.days_until_expiry} days"
  else
    "Your subscription is active"
  end
end
```

### Dynamic Components
```ruby
Dropdown(trigger_text: "Actions") do |dropdown|
  available_actions.each do |action|
    dropdown.item(
      text: action.label,
      href: action.path,
      icon: action.icon,
      disabled: !action.allowed_for?(current_user)
    )
  end
end
```

## Troubleshooting

### Component Not Rendering
- Ensure the component is properly imported
- Check that you're using `render` from Phlex
- Verify all required parameters are provided

### Styling Issues
- Make sure Tailwind CSS is properly configured
- Check for conflicting CSS classes
- Ensure the Preline CSS is loaded

### JavaScript Not Working
- Verify Stimulus controllers are loaded
- Check for JavaScript errors in console
- Ensure data attributes are properly set

## Additional Resources

- [Phlex Documentation](https://www.phlex.fun)
- [Preline UI Documentation](https://preline.co/docs)
- [Component Examples](https://github.com/enterprisemodules/phlex-preline)