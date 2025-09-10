# frozen_string_literal: true

module Phlex
  module Preline
    # Superform-native select field component with Preline UI styling
    class SelectField < BaseFieldComponent
      def initialize(name, **attributes)
        @options = attributes.delete(:options) || []
        @placeholder = attributes.delete(:placeholder)
        @multiple = attributes.delete(:multiple) || false
        @help_text = attributes.delete(:help)
        @aria_label = attributes.delete(:aria_label)
        @required = attributes.delete(:required) || false
        super
      end

      def view_template
        div(class: "form-field") do
          render_label if label?
          
          select(
            **accessible_attributes,
            **stimulus_bindings,
            multiple: @multiple,
            class: preline_classes
          ) do
            render_placeholder_option if @placeholder && !@multiple
            render_options
          end
          
          render_validation_feedback
          render_required_indicator if required?
        end
      end

      private

      def render_placeholder_option
        option(
          value: "",
          selected: field_value.blank?,
          disabled: required?
        ) do
          plain @placeholder
        end
      end

      def render_options
        @options.each do |option|
          case option
          when Hash
            option_value = option[:value] || option["value"]
            option_label = option[:label] || option["label"] || option_value
            
            option(
              value: option_value,
              selected: option_selected?(option_value)
            ) do
              plain option_label
            end
          when Array
            option_value = option[0]
            option_label = option[1] || option_value
            
            option(
              value: option_value,
              selected: option_selected?(option_value)
            ) do
              plain option_label
            end
          else
            option(
              value: option,
              selected: option_selected?(option)
            ) do
              plain option.to_s.humanize
            end
          end
        end
      end

      def option_selected?(value)
        if @multiple
          Array(field_value).include?(value.to_s)
        else
          field_value.to_s == value.to_s
        end
      end

      def field_value
        @field_value || (@multiple ? [] : "")
      end

      def required?
        @required
      end

      def custom_validation_rules
        rules = {}
        if @options.any?
          valid_values = @options.map do |opt|
            case opt
            when Hash then opt[:value] || opt["value"]
            when Array then opt[0]
            else opt
            end
          end
          rules[:enum] = valid_values
        end
        rules
      end

      def render_required_indicator
        span(
          class: "sr-only",
          id: "#{field_name}-required"
        ) { "Required field" }
      end
    end
  end
end