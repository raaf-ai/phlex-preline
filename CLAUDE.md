# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is Phlex-Preline UI Components - a comprehensive Ruby gem providing 79+ UI components built with Phlex for Rails applications. The gem includes theme system, internationalization (6 languages), accessibility support, and JavaScript integration via Stimulus controllers.

## Development Commands

**Testing and Linting:**
- `bundle exec rake spec` - Run RSpec tests
- `bundle exec rake rubocop` - Run RuboCop linting  
- `bundle exec rake` - Run both tests and linting (default task)

**Gem Management:**
- `bundle exec rake install` - Install gem locally
- `bundle exec rake release` - Release new version (updates git tag and pushes to rubygems.org)

## Architecture

**Main Entry Points:**
- `lib/preline.rb` - Main module with conditional Rails engine loading
- `lib/preline/engine.rb` - Rails engine that sets up autoload paths and asset configuration

**Component Organization:**
- `app/components/preline/preline_component.rb` - Base component with helper methods (`merge_classes`, `data_attributes`, `aria_attributes`)
- `app/components/preline/core/` - 79+ main UI components organized by category
- `app/components/preline/extension/` - Specialized components (ThemeToggle, LanguageSwitcher)
- `app/components/preline/loader.rb` - Orchestrates component loading using `Phlex::Kit`

**Key Dependencies:**
- **Runtime:** phlex (~> 1.0), phlex-rails (~> 1.0), i18n (~> 1.0)
- **Development:** rspec, rubocop

## Component Usage Guide

For comprehensive component usage examples and patterns, see [USAGE_GUIDE.md](USAGE_GUIDE.md). This file can be included in projects using this gem to provide AI assistants with detailed component documentation.

## Component Development Patterns

**Component Structure:**
- All components inherit from `PrelineComponent` base class
- Use `initialize_component()` for secure attribute handling
- Implement validation methods: `validate_inclusion!`, `validate_boolean!`
- Include ARIA attributes and semantic HTML by default

**Internationalization:**
- Locale files in `config/locales/` (EN, NL, DE, FR, ES, PT)
- Use `I18n.t()` for translatable strings
- Engine automatically loads locale files

**JavaScript Integration:**
- Stimulus controllers in `app/assets/javascripts/controllers/`
- Components can specify data attributes for controller integration
- Theme system uses sophisticated JavaScript for light/dark/system mode switching

**Styling:**
- CSS in `app/assets/stylesheets/preline-components.css`
- Uses CSS custom properties and Tailwind CSS patterns
- Theme-aware components with consistent class naming

## Version Management

- Version defined in `lib/preline/version.rb` as `Phlex::Preline::VERSION`
- Update version number before running `bundle exec rake release`