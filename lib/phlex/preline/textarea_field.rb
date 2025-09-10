# frozen_string_literal: true

module Phlex
  module Preline
    # Superform-native textarea field component with Preline UI styling
    class TextareaField < BaseFieldComponent
      def initialize(name, **attributes)
        @rows = attributes.delete(:rows) || 4
        @cols = attributes.delete(:cols)
        @placeholder = attributes.delete(:placeholder)
        @min_length = attributes.delete(:min_length)
        @max_length = attributes.delete(:max_length)
        @help_text = attributes.delete(:help)
        @aria_label = attributes.delete(:aria_label)
        @required = attributes.delete(:required) || false
        @resize = attributes.delete(:resize) || true
        super
      end

      def view_template
        div(class: "form-field") do
          render_label if label?
          
          textarea(
            **accessible_attributes,
            **stimulus_bindings,
            rows: @rows,
            cols: @cols,
            placeholder: @placeholder,
            minlength: @min_length,
            maxlength: @max_length,
            class: textarea_classes
          ) do
            plain field_value if field_value.present?
          end
          
          render_character_count if @max_length
          render_validation_feedback
          render_required_indicator if required?
        end
      end

      private

      def textarea_classes
        classes = [preline_classes]
        classes << "resize-none" unless @resize
        classes.join(" ")
      end

      def render_character_count
        return unless @max_length

        div(class: "mt-1 flex justify-end") do
          span(
            class: "text-xs text-gray-500",
            data: {
              "superform-field-target": "characterCount",
              "max-length": @max_length
            }
          ) do
            span(data: {"superform-field-target": "currentCount"}) { field_value.to_s.length }
            plain " / #{@max_length}"
          end
        end
      end

      def field_value
        @field_value || ""
      end

      def required?
        @required
      end

      def custom_validation_rules
        rules = {}
        rules[:textarea] = true
        rules
      end

      def render_required_indicator
        span(
          class: "sr-only",
          id: "#{field_name}-required"
        ) { "Required field" }
      end

      attr_reader :min_length, :max_length, :rows
    end
  end
end