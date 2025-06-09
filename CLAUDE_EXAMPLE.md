# Example CLAUDE.md for Projects Using Phlex-Preline

This is an example of how to include Phlex-Preline documentation in your project's CLAUDE.md file.

```markdown
# CLAUDE.md

This file provides guidance to Claude Code when working with this Rails application.

## Project Overview

[Your project description here]

## UI Components

This project uses Phlex-Preline UI components for the user interface. The components follow two patterns:

### Yielding Interface Pattern (Recommended for complex components)
```ruby
render Components::Preline::Dropdown.new(trigger_text: "Options") do |dropdown|
  dropdown.item(text: "Edit", href: "/edit")
  dropdown.item(text: "Delete", href: "/delete")
end
```

### Direct Content Pattern (For simple content)
```ruby
render Components::Preline::Alert.new(type: :success) do
  "Operation completed successfully!"
end
```

### Component Documentation

For detailed component usage, refer to:
- Component list and examples: https://github.com/enterprisemodules/phlex-preline/blob/main/USAGE_GUIDE.md
- Full documentation: https://github.com/enterprisemodules/phlex-preline

### Common UI Patterns in This Project

#### Navigation
Our main navigation uses the Navbar component with dropdowns:
```ruby
# app/views/layouts/application.html.erb
render Components::Preline::Navbar.new(sticky: true) do |navbar|
  navbar.brand(text: "MyApp", href: root_path)
  # ... navigation items
end
```

#### Forms
We use Preline form components with Rails form helpers:
```ruby
# app/views/users/_form.html.erb
render Components::Preline::Form.new do |form|
  form.input(
    name: "user[email]",
    type: "email",
    label: "Email",
    value: @user.email,
    errors: @user.errors[:email]
  )
end
```

#### Modals and Alerts
For user feedback:
```ruby
# Show success message
render Components::Preline::Alert.new(
  type: :success,
  dismissible: true
) { "User created successfully!" }

# Confirmation modal
render Components::Preline::Modal.new(id: "confirm-delete") do |modal|
  modal.header(title: "Confirm Deletion")
  modal.body { "Are you sure?" }
  modal.footer do
    # ... buttons
  end
end
```

## Development Guidelines

1. Always use the Preline components for UI consistency
2. Prefer the yielding interface for complex components
3. Follow the established patterns in existing views
4. Ensure all interactive components have proper ARIA labels
5. Test responsive behavior on mobile devices

## Testing

When testing views with Preline components:
```ruby
expect(page).to have_css('.hs-dropdown')
expect(page).to have_button('Options')
```
```