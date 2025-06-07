# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release with 79+ UI components
- Theme system with light/dark mode support
- Internationalization support for 6 languages (EN, NL, DE, FR, ES, PT)
- Accessibility features with ARIA attributes
- JavaScript integration via Stimulus controllers
- Security features with XSS prevention
- Comprehensive validation framework

### Fixed
- Added ActiveSupport as runtime dependency
- Fixed tooltip component's hard dependency on Rails
- Moved SecureAttributes and Validatable modules to lib/preline
- Removed redundant engine.rb and loader.rb files

### Security
- Implemented secure attribute handling to prevent XSS attacks
- Added URL validation to prevent javascript: and data: protocols
- Sanitization of user inputs across all components

## [0.1.0] - 2024-01-01

### Added
- Initial beta release

[Unreleased]: https://github.com/enterprisemodules/preline/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/enterprisemodules/preline/releases/tag/v0.1.0