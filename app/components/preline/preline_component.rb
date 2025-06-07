# frozen_string_literal: true

module Components
  module Preline
    # Base class for all Preline UI components
    # Provides common functionality and includes necessary modules
    class PrelineComponent < BaseComponent
      # Common helper methods for Preline components can be added here

      private

      # Helper to build data attributes
      def data_attributes(attributes = {})
        attributes.transform_keys { |key| "data-#{key.to_s.dasherize}" }
      end

      # Helper to build aria attributes
      def aria_attributes(attributes = {})
        attributes.transform_keys { |key| "aria-#{key.to_s.dasherize}" }
      end

      # Initialize component with secure attribute handling
      def initialize_component(attrs = {})
        @custom_class = attrs.delete(:class)
        @data_attrs = attrs.delete(:data) || {}
        @aria_attrs = attrs.delete(:aria) || {}
        @attrs = attrs
      end

      # Build component attributes for rendering
      def component_attributes(additional_classes: [], additional_attrs: {})
        extracted = extract_attributes(@attrs)
        attrs = merge_attributes(extracted, additional_attrs)

        # Add additional classes
        if additional_classes.any?
          existing_classes = attrs[:class].to_s.split
          attrs[:class] = (existing_classes + additional_classes).uniq.join(' ')
        end

        attrs
      end
    end
  end
end
