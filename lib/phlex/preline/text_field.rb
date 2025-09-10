# frozen_string_literal: true

module Phlex
  module Preline
    # Superform-native text field component with Preline UI styling
    class TextField < BaseFieldComponent
      def initialize(name, **attributes)
        @field_type = attributes.delete(:type) || :text
        @placeholder = attributes.delete(:placeholder)
        @min_length = attributes.delete(:min_length)
        @max_length = attributes.delete(:max_length)
        @pattern = attributes.delete(:pattern)
        @help_text = attributes.delete(:help)
        @aria_label = attributes.delete(:aria_label)
        @required = attributes.delete(:required) || false
        super
      end

      def view_template
        div(class: "form-field") do
          render_label if label?
          
          input(
            **accessible_attributes,
            **stimulus_bindings,
            type: input_type,
            value: field_value,
            placeholder: @placeholder,
            minlength: @min_length,
            maxlength: @max_length,
            pattern: @pattern&.source,
            class: preline_classes
          )
          
          render_validation_feedback
          render_required_indicator if required?
        end
      end

      private

      def input_type
        case @field_type
        when :email then "email"
        when :url then "url"  
        when :tel then "tel"
        when :password then "password"
        when :number then "number"
        else "text"
        end
      end

      def field_value
        # Get value from form object or model
        @field_value || ""
      end

      def required?
        @required
      end

      def custom_validation_rules
        rules = {}
        rules[:email] = true if @field_type == :email
        rules[:url] = true if @field_type == :url
        rules
      end

      def render_required_indicator
        span(
          class: "sr-only",
          id: "#{field_name}-required"
        ) { "Required field" }
      end

      attr_reader :min_length, :max_length, :pattern, :field_type
    end
  end
end