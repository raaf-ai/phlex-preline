# Phlex-Preline UI Components

[![CI](https://github.com/enterprisemodules/phlex-preline/actions/workflows/ci.yml/badge.svg)](https://github.com/enterprisemodules/phlex-preline/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/phlex-preline.svg)](https://badge.fury.io/rb/phlex-preline)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive AI build UI component library built with Phlex for Rails applications, featuring 79+ professionally designed components with complete theme system, internationalization, and accessibility support.

## Features

- **79+ Production-Ready Components** covering all common interface patterns
- **Advanced Theme System** with light/dark/system modes and CSS custom properties
- **Complete Internationalization** support for 6 languages (EN, NL, DE, FR, ES, PT)
- **Enterprise Security** with XSS protection and secure attribute handling
- **Seamless JavaScript Integration** with Stimulus controllers
- **Full Accessibility Support** with ARIA attributes and semantic HTML
- **Mobile-First Responsive Design** with Tailwind CSS integration
- **Rails Form Integration** with form builders and model binding

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'phlex-preline'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install phlex-preline

## Quick Start

1. **Add the CSS** to your application's stylesheet:

```scss
@import "preline-components";
@import "themes"; /* Optional: Include theme system with CSS variables */
```

2. **Include JavaScript** for interactive components (Stimulus):

```javascript
// app/javascript/controllers/application.js
import { Application } from "@hotwired/stimulus"
import PrelineControllers from "phlex-preline/controllers"

const application = Application.start()
PrelineControllers.register(application)
```

3. **Use components** in your Phlex views:

```ruby
class DashboardView < Phlex::HTML
  include Phlex::Preline::Components

  def view_template
    Container do
      Alert(variant: :success, dismissible: true) do
        "Welcome to your dashboard!"
      end
      
      Card do
        CardHeader(title: "User Profile")
        CardBody do
          Form(model: @user) do |f|
            f.Input(attribute: :name, label: "Full Name")
            f.Select(attribute: :role, options: role_options)
            f.ButtonGroup do
              f.Button("Save", variant: :primary)
              f.Button("Cancel", variant: :outline)
            end
          end
        end
      end
    end
  end
end
```

## Complete Component Library

### 🏗️ Layout & Structure (7 components)
- **Container** - Responsive page layout wrapper with max-widths and centering
- **Grid** - CSS Grid system with responsive breakpoints and gap controls
- **Flex** - Flexbox layouts with direction, wrap, and alignment utilities
- **Columns** - Multi-column layouts for text and content flow
- **Divider** - Visual separators with text, icons, and custom styling
- **Layout Splitter** - Resizable panels with drag handles and persistence
- **Devices** - Device-specific responsive display controls

### 📝 Forms & Inputs (21 components)
- **Form** - Rails form integration with model binding and validation display
- **Input** - Text inputs with validation states, icons, and accessibility features
- **Input Group** - Grouped inputs with addons, buttons, and combined validation
- **Input Number** - Numeric inputs with increment/decrement controls and limits
- **Text Area** - Multi-line text inputs with auto-resize and character counting
- **Select** - Dropdown selections with search, multi-select, and custom options
- **Advanced Select** - Enhanced select with filtering, tagging, and async loading
- **Combo Box** - Searchable select with keyboard navigation and custom values
- **Search Box** - Dedicated search inputs with suggestions and recent searches
- **Checkbox** - Single and grouped checkboxes with indeterminate states
- **Radio** - Radio button groups with inline and stacked layouts
- **Switch** - Toggle switches with labels, descriptions, and disabled states
- **File Input** - File upload with drag-drop, previews, and progress indicators
- **File Upload Progress** - Real-time upload progress with cancellation support
- **Pin Input** - PIN/code entry with auto-focus and paste support
- **Color Picker** - Color selection with swatches, hex input, and opacity
- **Date Picker** - Calendar widget with ranges, restrictions, and internationalization
- **Time Picker** - Time selection with 12/24 hour formats and step controls
- **Range Slider** - Single and dual-handle sliders with marks and tooltips
- **Strong Password** - Password inputs with strength indicators and requirements
- **Toggle Password** - Password visibility toggle with secure state management

### 🧭 Navigation (12 components)
- **Navbar** - Responsive navigation bars with branding, menus, and actions
- **Navs** - Tab and pill navigation with active states and disabled items
- **Tabs** - Tabbed interfaces with content panels and lazy loading
- **Breadcrumb** - Hierarchical navigation with separators and structured data
- **Pagination** - Page navigation with first/last, ellipsis, and custom ranges
- **Sidebar** - Collapsible sidebars with nested menus and state persistence
- **Mega Menu** - Large dropdown menus with columns, images, and rich content
- **Offcanvas** - Slide-out panels from any side with backdrop and focus management
- **Scrollspy** - Automatic navigation highlighting based on scroll position
- **Context Menu** - Right-click menus with nested items and keyboard navigation
- **Dropdown** - Dropdown menus with positioning, triggers, and item groups
- **Tree View** - Hierarchical data display with expand/collapse and selection

### 🎨 Buttons & Actions (4 components)
- **Button** - Comprehensive button component with variants, sizes, and loading states
- **Button Group** - Grouped buttons with exclusive selection and toolbar layouts
- **Link** - Styled links with variants, icons, and external link handling
- **Copy Markup** - Copy-to-clipboard functionality with feedback and formatting

### 📊 Data Display (14 components)
- **Table** - Feature-rich data tables with sorting, filtering, and pagination
- **List** - Simple and complex lists with descriptions, actions, and avatars
- **List Group** - Grouped list items with badges, actions, and flush styling
- **Card** - Content cards with headers, bodies, footers, and image overlays
- **Badge** - Status indicators with variants, sizes, and positioning options
- **Avatar** - User avatars with images, initials, status indicators, and sizes
- **Avatar Group** - Grouped avatars with overflow handling and hover effects
- **Image** - Responsive images with loading states, fallbacks, and overlays
- **Typography** - Text styling utilities for headings, body text, and emphasis
- **Blockquote** - Quote blocks with attribution and custom styling
- **Ratings** - Star ratings with half-stars, readonly mode, and custom icons
- **Legend Indicator** - Chart legends and data key displays
- **Timeline** - Event timelines with branching, dates, and rich content
- **Chat Bubble** - Message bubbles for chat interfaces with timestamps

### 💬 Feedback & Overlays (8 components)
- **Alert** - Notification alerts with variants, dismissibility, and actions
- **Toast** - Temporary notifications with positioning, auto-dismiss, and stacking
- **Modal** - Dialog modals with sizes, backdrop options, and focus management
- **Popover** - Contextual popovers with rich content and smart positioning
- **Tooltip** - Hover tooltips with delays, triggers, and accessibility
- **Progress** - Progress indicators with labels, animations, and multiple bars
- **Spinner** - Loading spinners with sizes, colors, and accessibility labels
- **Skeleton** - Loading placeholders with realistic content structure

### 🎛️ Interactive Elements (8 components)
- **Accordion** - Collapsible content sections with single/multi-expand modes
- **Collapse** - Show/hide content with smooth animations and state persistence
- **Carousel** - Image and content carousels with navigation, indicators, and auto-play
- **Stepper** - Step-by-step processes with validation, navigation, and progress
- **Toggle Count** - Interactive counters with increment/decrement and limits
- **Custom Scrollbar** - Styled scrollbars with themes and responsive behavior
- **Styled Icons** - Icon display utilities with FontAwesome integration
- **Scrollspy** - Content highlighting based on scroll position

### 🔧 Specialized Components (2 components)
- **KBD** - Keyboard key styling for documentation and shortcuts
- **Devices** - Device-specific display controls for responsive design

### 🎨 Extension Components (2 components)
- **Theme Toggle** - Light/dark/system theme switcher with persistence
- **Language Switcher** - Multi-language selection with flag icons and localization

## Component Features

### 🎨 **Theme System**
All components support the comprehensive theme system:
- **Light Mode** - Clean, bright interface
- **Dark Mode** - Easy-on-eyes dark interface  
- **System Mode** - Automatically follows OS preference
- **CSS Custom Properties** - Easy customization and branding

### 🌍 **Internationalization**
Complete i18n support with professional translations:
- **English** (en) - Default language
- **Dutch** (nl) - Nederlandse vertaling
- **German** (de) - Deutsche Übersetzung
- **French** (fr) - Traduction française
- **Spanish** (es) - Traducción española
- **Portuguese** (pt) - Tradução portuguesa

### ♿ **Accessibility First**
Every component includes:
- **ARIA attributes** for screen readers
- **Keyboard navigation** support
- **Focus management** and visual indicators
- **Semantic HTML** structure
- **Color contrast** compliance

### 🔒 **Security & Validation**
Enterprise-grade security features:
- **XSS protection** through validated inputs
- **Secure attribute handling** with parameter validation
- **Input sanitization** and type checking
- **CSRF protection** integration with Rails

### 📱 **Responsive Design**
Mobile-first approach with:
- **Breakpoint-aware** components
- **Touch-friendly** interactions
- **Adaptive layouts** for all screen sizes
- **Performance optimized** for mobile networks

## Example Patterns

### Building a Complete Dashboard

```ruby
class DashboardView < Phlex::HTML
  include Phlex::Preline::Components

  def view_template
    div(class: "min-h-screen theme-bg-primary") do
      # Navigation
      Navbar(class: "border-b theme-border") do
        NavbarBrand(text: "MyApp", href: "/")
        NavbarNav do
          NavItem(text: "Dashboard", href: "/dashboard", active: true)
          NavItem(text: "Users", href: "/users")
          NavItem(text: "Settings", href: "/settings")
        end
        NavbarActions do
          ThemeToggle()
          LanguageSwitcher()
        end
      end

      Container(class: "py-8") do
        # Stats Cards
        Grid(cols: { default: 1, md: 2, lg: 4 }, gap: 6) do
          stat_card("Total Users", @stats[:users], "fas fa-users", :blue)
          stat_card("Revenue", @stats[:revenue], "fas fa-dollar-sign", :green)
          stat_card("Orders", @stats[:orders], "fas fa-shopping-cart", :purple)
          stat_card("Growth", @stats[:growth], "fas fa-chart-line", :orange)
        end

        # Main Content
        Grid(cols: { default: 1, lg: 3 }, gap: 8, class: "mt-8") do
          div(class: "lg:col-span-2") do
            Card do
              CardHeader(title: "Recent Activity")
              CardBody do
                Table(striped: true, hover: true) do
                  TableHead do
                    TableRow do
                      TableHeader("User")
                      TableHeader("Action") 
                      TableHeader("Date")
                      TableHeader("Status")
                    end
                  end
                  TableBody do
                    @activities.each do |activity|
                      TableRow do
                        TableData do
                          div(class: "flex items-center space-x-3") do
                            Avatar(src: activity.user.avatar, size: :sm)
                            span(activity.user.name)
                          end
                        end
                        TableData(activity.action)
                        TableData(activity.created_at.strftime("%B %d, %Y"))
                        TableData do
                          Badge(text: activity.status, variant: badge_variant(activity.status))
                        end
                      end
                    end
                  end
                end
              end
            end
          end

          div do
            Card do
              CardHeader(title: "Quick Actions")
              CardBody do
                ButtonGroup(orientation: :vertical, class: "w-full") do
                  Button("Add User", variant: :primary, icon: "fas fa-plus", class: "justify-start")
                  Button("Export Data", variant: :outline, icon: "fas fa-download", class: "justify-start")
                  Button("Send Newsletter", variant: :outline, icon: "fas fa-envelope", class: "justify-start")
                end
              end
            end
          end
        end
      end
    end
  end

  private

  def stat_card(title, value, icon, color)
    Card(class: "text-center") do
      CardBody do
        div(class: "flex items-center justify-between") do
          div do
            div(class: "text-2xl font-bold theme-text-primary", value)
            div(class: "text-sm theme-text-secondary", title)
          end
          div(class: "text-3xl text-#{color}-500") do
            i(class: icon)
          end
        end
      end
    end
  end

  def badge_variant(status)
    case status.downcase
    when "completed" then :success
    when "pending" then :warning
    when "failed" then :danger
    else :secondary
    end
  end
end
```

### Form Building with Validation

```ruby
class UserFormView < Phlex::HTML
  include Phlex::Preline::Components

  def view_template
    Container(size: :md) do
      Card do
        CardHeader(title: "User Registration")
        CardBody do
          Form(model: @user, local: true) do |f|
            Grid(cols: { default: 1, md: 2 }, gap: 6) do
              f.Input(
                attribute: :first_name,
                label: "First Name",
                required: true,
                placeholder: "Enter your first name"
              )
              
              f.Input(
                attribute: :last_name,
                label: "Last Name", 
                required: true,
                placeholder: "Enter your last name"
              )
            end

            f.Input(
              attribute: :email,
              type: :email,
              label: "Email Address",
              required: true,
              helper_text: "We'll never share your email with anyone else."
            )

            f.Input(
              attribute: :password,
              type: :password,
              label: "Password",
              required: true,
              helper_text: "Minimum 8 characters with mixed case and numbers"
            )

            f.Select(
              attribute: :role,
              label: "Role",
              options: role_options,
              required: true
            )

            f.Switch(
              attribute: :email_notifications,
              label: "Email Notifications",
              helper_text: "Receive updates about your account"
            )

            Divider(class: "my-6")

            ButtonGroup do
              f.Button("Create Account", variant: :primary, type: :submit)
              f.Button("Cancel", variant: :outline, href: users_path)
            end
          end
        end
      end
    end
  end

  private

  def role_options
    [
      ["User", "user"],
      ["Admin", "admin"],
      ["Manager", "manager"]
    ]
  end
end
```

### Advanced Layout with Sidebar

```ruby
class ApplicationLayout < Phlex::HTML
  include Phlex::Preline::Components

  def view_template
    div(class: "flex h-screen theme-bg-primary") do
      # Sidebar
      Sidebar(collapsible: true, width: :sm) do
        SidebarHeader do
          div(class: "flex items-center space-x-3") do
            Avatar(initials: "MA", size: :sm)
            div do
              div(class: "font-semibold theme-text-primary", "My App")
              div(class: "text-xs theme-text-secondary", "v1.0.0")
            end
          end
        end

        SidebarContent do
          nav_item("Dashboard", "/dashboard", "fas fa-tachometer-alt")
          nav_item("Users", "/users", "fas fa-users")
          nav_item("Products", "/products", "fas fa-box")
          nav_item("Orders", "/orders", "fas fa-shopping-cart")
          
          SidebarSection(title: "Management") do
            nav_item("Analytics", "/analytics", "fas fa-chart-bar")
            nav_item("Reports", "/reports", "fas fa-file-alt")
            nav_item("Settings", "/settings", "fas fa-cog")
          end
        end

        SidebarFooter do
          ThemeToggle(size: :sm)
          LanguageSwitcher()
        end
      end

      # Main Content
      div(class: "flex-1 flex flex-col overflow-hidden") do
        # Top Bar
        div(class: "bg-white border-b border-gray-200 px-6 py-4") do
          div(class: "flex items-center justify-between") do
            h1(class: "text-2xl font-semibold theme-text-primary", @page_title)
            
            div(class: "flex items-center space-x-4") do
              SearchBox(placeholder: "Search...")
              
              Dropdown(trigger_text: current_user.name, trigger_variant: :ghost) do
                DropdownItem(text: "Profile", href: profile_path)
                DropdownItem(text: "Settings", href: settings_path)
                DropdownDivider()
                DropdownItem(text: "Sign Out", href: logout_path, method: :delete)
              end
            end
          end
        end

        # Page Content
        main(class: "flex-1 overflow-y-auto p-6") do
          yield
        end
      end
    end
  end

  private

  def nav_item(text, href, icon)
    SidebarItem(
      text: text,
      href: href,
      icon: icon,
      active: current_page?(href)
    )
  end
end
```

## Usage Guide

For detailed component usage examples and best practices, see the [USAGE_GUIDE.md](USAGE_GUIDE.md) file. This guide can be included in your project's Claude.md file for AI-assisted development:

```markdown
# In your project's CLAUDE.md file:

## UI Components

This project uses Phlex-Preline UI components. See the component usage guide:
https://github.com/yourusername/yourproject/blob/main/vendor/bundle/ruby/3.2.0/gems/phlex-preline-1.0.0/USAGE_GUIDE.md

Or if you have the gem source locally:
/path/to/phlex-preline/USAGE_GUIDE.md
```

The usage guide includes:
- ✅ Complete component reference with examples
- ✅ Both yielding interface and direct content patterns
- ✅ Common UI patterns and best practices
- ✅ Accessibility guidelines
- ✅ Troubleshooting tips

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/enterprisemodules/preline.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).