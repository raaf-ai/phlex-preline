# Preline UI Components

A comprehensive set of UI components built with Phlex and designed for Rails applications.

## Structure

```
preline/
├── core/                  # Core UI components (buttons, cards, modals, etc.)
├── extension/             # Custom extension components
├── locales/              # Internationalization files
├── loader.rb             # Main loader that requires all components
├── preline_component.rb  # Base class for all Preline components
├── extension.rb          # Extension module loader
├── engine.rb             # Rails engine configuration (for gem extraction)
├── version.rb            # Version management
└── README.md             # This file
```

## Components

### Core Components
- **Layout**: Container, Grid, Flex, Columns
- **Forms**: Input, Select, TextArea, Switch, FileInput
- **Navigation**: Navbar, Tabs, Breadcrumb, Pagination
- **Feedback**: Alert, Toast, Modal, Progress
- **Data Display**: List, Table, Badge, Avatar, Card
- **Actions**: Button, Link, Dropdown

### Extension Components
- **LanguageSwitcher**: Multi-language selection dropdown
- **ThemeToggle**: Light/dark/system theme switcher

## Usage

```ruby
# In your component or view
class MyComponent < Components::BaseComponent
  include Components::Preline
  include Components::Preline::Extension
  
  def view_template
    Container do
      Button(text: "Click me", variant: :primary)
      ThemeToggle()
      LanguageSwitcher()
    end
  end
end
```

## Internationalization

All text strings are internationalized using the `preline.*` namespace:
- `preline.language_switcher.*` - Language names
- `preline.theme_toggle.*` - Theme options
- `preline.pagination.*` - Pagination text
- `preline.modal.*` - Modal text
- `preline.file_input.*` - File input text

## Gem Extraction

This structure is designed to be easily extracted as a Rails engine/gem. The `engine.rb` file contains the necessary Rails engine configuration for when this becomes a standalone gem.

## Version

Current version: 0.1.0