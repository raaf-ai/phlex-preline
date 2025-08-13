# frozen_string_literal: true

module Components
  module Preline
    # Base class for all Preline UI components.
    # Extends BaseComponent with Preline-specific functionality including
    # data attribute helpers, ARIA attribute helpers, and secure attribute handling.
    # All Preline UI components should inherit from this class.
    #
    # @abstract Subclass to create specific Preline UI components
    # @since 0.1.0
    # @api public
    #
    # @example Creating a custom Preline component
    #   class MyCustomComponent < PrelineComponent
    #     def initialize(text:, **attrs)
    #       @text = text
    #       initialize_component(attrs)
    #     end
    #
    #     def view_template
    #       div(**component_attributes(additional_classes: 'my-component')) do
    #         plain @text
    #       end
    #     end
    #   end
    class PrelineComponent < BaseComponent
      # Common helper methods for Preline components

      private

      # Transforms a hash of attributes into data-* attributes for HTML.
      # Converts underscored keys to dasherized data attribute names.
      #
      # @param attributes [Hash] Hash of data attributes
      # @return [Hash] Transformed hash with data-* prefixed keys
      # @api private
      #
      # @example
      #   data_attributes(controller: 'dropdown', action: 'click')
      #   # => { "data-controller" => "dropdown", "data-action" => "click" }
      def data_attributes(attributes = {})
        attributes.transform_keys { |key| "data-#{key.to_s.dasherize}" }
      end

      # Transforms a hash of attributes into aria-* attributes for accessibility.
      # Converts underscored keys to dasherized ARIA attribute names.
      #
      # @param attributes [Hash] Hash of ARIA attributes
      # @return [Hash] Transformed hash with aria-* prefixed keys
      # @api private
      #
      # @example
      #   aria_attributes(label: 'Close', expanded: true)
      #   # => { "aria-label" => "Close", "aria-expanded" => true }
      def aria_attributes(attributes = {})
        attributes.transform_keys { |key| "aria-#{key.to_s.dasherize}" }
      end
    end
  end
end
