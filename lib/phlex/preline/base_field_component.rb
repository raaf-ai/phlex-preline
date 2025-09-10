# frozen_string_literal: true

require 'superform'

module Phlex
  module Preline
    # Base class for all Superform-native Phlex-Preline field components
    # Provides common functionality for form fields with Preline UI styling
    class BaseFieldComponent < Superform::Field
      include Phlex::Rails::Helpers::FormWith if defined?(Phlex::Rails)

      # Preline UI base classes for form fields
      BASE_FIELD_CLASSES = [
        "block w-full rounded-md border-0 py-1.5 px-3 text-gray-900 shadow-sm ring-1 ring-inset",
        "placeholder:text-gray-400 focus:ring-2 focus:ring-inset sm:text-sm sm:leading-6"
      ].freeze

      BASE_ERROR_CLASSES = [
        "ring-red-300 focus:ring-red-500"
      ].freeze

      BASE_SUCCESS_CLASSES = [
        "ring-gray-300 focus:ring-blue-600"
      ].freeze

      private

      # Generate Preline UI classes based on field state
      def preline_classes
        classes = BASE_FIELD_CLASSES.dup
        
        if has_errors?
          classes.concat(BASE_ERROR_CLASSES)
        else
          classes.concat(BASE_SUCCESS_CLASSES)
        end

        classes.concat(custom_classes) if respond_to?(:custom_classes, true)
        classes.join(" ")
      end

      # Generate Stimulus data attributes for validation
      def stimulus_bindings
        {
          controller: "superform-field",
          action: "input->superform-field#validate change->superform-field#autosave",
          "superform-field-name-value": field_name,
          "superform-field-rules-value": validation_schema.to_json
        }
      end

      # Generate JavaScript validation schema from field definition
      def validation_schema
        schema = {}
        
        # Required validation
        schema[:required] = true if required?
        
        # Length validations
        schema[:minLength] = min_length if respond_to?(:min_length) && min_length
        schema[:maxLength] = max_length if respond_to?(:max_length) && max_length
        
        # Pattern validation
        schema[:pattern] = pattern.source if respond_to?(:pattern) && pattern.is_a?(Regexp)
        
        # Type validation
        schema[:type] = field_type if respond_to?(:field_type)
        
        # Custom validation rules
        schema.merge!(custom_validation_rules) if respond_to?(:custom_validation_rules, true)
        
        schema
      end

      # Render validation feedback (errors, help text)
      def render_validation_feedback
        return unless has_errors? || help_text?

        div(class: "mt-1") do
          # Error messages
          if has_errors?
            errors.each do |error|
              p(class: "text-sm text-red-600", id: "#{field_name}-error") do
                plain error
              end
            end
          end

          # Help text
          if help_text? && !has_errors?
            p(class: "text-sm text-gray-500", id: "#{field_name}-help") do
              plain help_text
            end
          end
        end
      end

      # Render field label with required indicator
      def render_label
        return unless label?

        label(
          for: field_id,
          class: "block text-sm font-medium text-gray-700 mb-1"
        ) do
          plain label_text
          if required?
            span(class: "text-red-500 ml-1") { "*" }
          end
        end
      end

      # Generate accessible field attributes
      def accessible_attributes
        attrs = {
          id: field_id,
          name: field_name,
          required: required?,
          "aria-label": aria_label || label_text
        }

        # ARIA descriptions
        describedby_parts = []
        describedby_parts << "#{field_name}-help" if help_text?
        describedby_parts << "#{field_name}-error" if has_errors?
        describedby_parts << "#{field_name}-required" if required?
        
        attrs["aria-describedby"] = describedby_parts.join(" ") if describedby_parts.any?
        attrs["aria-invalid"] = "true" if has_errors?

        attrs
      end

      # Helper methods
      def field_id
        @field_id ||= "#{form_name}_#{field_name}"
      end

      def has_errors?
        errors.any?
      end

      def help_text?
        help_text.present?
      end

      def required?
        # Override in subclasses based on field definition
        false
      end

      def label?
        label_text.present?
      end

      def label_text
        @label_text ||= field_name.to_s.humanize
      end

      def help_text
        @help_text
      end

      def aria_label
        @aria_label
      end

      def errors
        @errors ||= []
      end

      def field_name
        @field_name ||= name.to_s
      end

      def form_name
        @form_name ||= "form"
      end
    end
  end
end