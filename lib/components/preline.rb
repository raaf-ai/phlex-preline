# frozen_string_literal: true

# This file sets up the Components::Preline module structure
# and ensures all components are properly autoloaded

module Components
  # Provides UI components for Phlex-based Rails applications
  module Preline
    extend ::Phlex::Kit

    # Extension module for extension components
    module Extension
      extend ::Phlex::Kit
    end

    # Configuration methods
    class << self
      # Configure Components::Preline
      #
      # @example
      #   Components::Preline.configure do |config|
      #     config.bypass_security_checks = true
      #   end
      def configure
        yield self
      end

      # Enable or disable security checks for attributes
      #
      # @param value [Boolean] true to bypass security checks, false to enable them (default: false)
      # @example
      #   Components::Preline.bypass_security_checks = true
      def bypass_security_checks=(value)
        ::Phlex::Preline::SecureAttributes.bypass_security_checks = value
      end

      # Check if security checks are bypassed
      #
      # @return [Boolean] true if security checks are bypassed
      def bypass_security_checks
        ::Phlex::Preline::SecureAttributes.bypass_security_checks
      end

      # Check if security checks are bypassed (alias)
      #
      # @return [Boolean] true if security checks are bypassed
      def bypass_security_checks?
        ::Phlex::Preline::SecureAttributes.bypass_security_checks
      end

      # Add allowed HTML attributes
      #
      # @param attributes [Array<Symbol>] HTML attributes to allow
      # @example
      #   Components::Preline.allow_html_attributes(:contenteditable, :draggable)
      def allow_html_attributes(*attributes)
        ::Phlex::Preline::SecureAttributes.allowed_html_attributes.concat(attributes.map(&:to_sym)).uniq!
      end

      # Add allowed data attributes
      #
      # @param attributes [Array<String>] Data attribute names (without data- prefix)
      # @example
      #   Components::Preline.allow_data_attributes('tooltip', 'popover-content')
      def allow_data_attributes(*attributes)
        ::Phlex::Preline::SecureAttributes.allowed_data_attributes.concat(attributes.map(&:to_s)).uniq!
      end

      # Add allowed ARIA attributes
      #
      # @param attributes [Array<String>] ARIA attribute names (without aria- prefix)
      # @example
      #   Components::Preline.allow_aria_attributes('roledescription', 'keyshortcuts')
      def allow_aria_attributes(*attributes)
        ::Phlex::Preline::SecureAttributes.allowed_aria_attributes.concat(attributes.map(&:to_s)).uniq!
      end

      # Add patterns for allowed data attributes
      #
      # @param patterns [Array<String, Regexp>] Patterns to match data attributes
      # @example
      #   Components::Preline.allow_data_patterns(/^analytics-/, 'tracking-')
      def allow_data_patterns(*patterns)
        ::Phlex::Preline::SecureAttributes.allowed_data_patterns.concat(patterns).uniq!
      end

      # Reset allow lists to defaults
      #
      # @example
      #   Components::Preline.reset_allowed_attributes!
      def reset_allowed_attributes!
        ::Phlex::Preline::SecureAttributes.allowed_html_attributes =
          ::Phlex::Preline::SecureAttributes::DEFAULT_ALLOWED_HTML_ATTRIBUTES.dup
        ::Phlex::Preline::SecureAttributes.allowed_data_attributes =
          ::Phlex::Preline::SecureAttributes::DEFAULT_ALLOWED_DATA_ATTRIBUTES.dup
        ::Phlex::Preline::SecureAttributes.allowed_aria_attributes =
          ::Phlex::Preline::SecureAttributes::DEFAULT_ALLOWED_ARIA_ATTRIBUTES.dup
        ::Phlex::Preline::SecureAttributes.allowed_data_patterns = []
      end

      # Get current allowed attributes
      #
      # @return [Hash] Hash of current allow lists
      def allowed_attributes
        {
          html: ::Phlex::Preline::SecureAttributes.allowed_html_attributes,
          data: ::Phlex::Preline::SecureAttributes.allowed_data_attributes,
          aria: ::Phlex::Preline::SecureAttributes.allowed_aria_attributes,
          data_patterns: ::Phlex::Preline::SecureAttributes.allowed_data_patterns
        }
      end
    end
  end
end
