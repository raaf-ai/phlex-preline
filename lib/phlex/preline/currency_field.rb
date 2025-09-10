# frozen_string_literal: true

module Phlex
  module Preline
    # Superform-native currency field with K/M/B formatting and validation
    class CurrencyField < BaseFieldComponent
      def initialize(name, **attributes)
        @currency = attributes.delete(:currency) || "USD"
        @placeholder = attributes.delete(:placeholder) || "e.g., 1M, 500K, 2.5B"
        @help_text = attributes.delete(:help)
        @aria_label = attributes.delete(:aria_label) || "Currency amount"
        @required = attributes.delete(:required) || false
        super
      end

      def view_template
        div(class: "form-field") do
          render_label if label?
          
          div(
            class: "relative rounded-md shadow-sm",
            data: {
              controller: "currency-field superform-field",
              action: "input->currency-field#formatValue blur->currency-field#validateValue input->superform-field#validate blur->superform-field#validateImmediate",
              "superform-field-name-value": field_name,
              "superform-field-rules-value": validation_schema.to_json,
              "currency-field-currency-value": @currency
            }
          ) do
            render_currency_symbol
            render_input_field
            render_currency_selector
          end
          
          render_help_text if @help_text
          render_validation_feedback
          render_required_indicator if required?
        end
      end

      private

      def render_currency_symbol
        div(class: "absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none") do
          span(class: "text-gray-500 sm:text-sm") { currency_symbol }
        end
      end

      def render_input_field
        input(
          **accessible_attributes,
          **stimulus_bindings,
          type: "text",
          class: currency_input_classes,
          placeholder: @placeholder,
          data: {
            "currency-field-target": "input",
            "superform-field-target": "field",
            action: "input->currency-field#formatValue input->superform-field#validate input->superform-field#updateCharacterCount"
          }
        )
      end

      def render_currency_selector
        div(class: "absolute inset-y-0 right-0 flex items-center") do
          select(
            name: currency_field_name,
            class: "h-full py-0 pl-2 pr-7 border-transparent bg-transparent text-gray-500 sm:text-sm rounded-md focus:ring-blue-500 focus:border-blue-500",
            data: {
              "currency-field-target": "currencySelect",
              action: "change->currency-field#updateCurrency"
            }
          ) do
            currency_options.each do |option_value, option_text|
              option(
                value: option_value,
                selected: @currency == option_value
              ) { option_text }
            end
          end
        end
      end

      def render_help_text
        p(class: "mt-1 text-sm text-gray-500") do
          plain @help_text
          span(class: "block mt-1 text-xs text-gray-400") do
            "Examples: 1M (1 million), 500K (500 thousand), 2.5B (2.5 billion)"
          end
        end
      end

      def currency_input_classes
        [
          "block w-full pl-12 pr-20 py-2 border rounded-md shadow-sm",
          "focus:ring-blue-500 focus:border-blue-500 sm:text-sm",
          error_styling? ? "border-red-300 text-red-900 placeholder-red-300" : "border-gray-300 placeholder-gray-400"
        ].join(" ")
      end

      def currency_symbol
        case @currency
        when "USD" then "$"
        when "EUR" then "€"  
        when "GBP" then "£"
        when "JPY" then "¥"
        when "CAD" then "C$"
        when "AUD" then "A$"
        when "CHF" then "Fr"
        when "CNY" then "¥"
        when "INR" then "₹"
        when "SEK", "NOK", "DKK" then "kr"
        else @currency
        end
      end

      def currency_field_name
        # Convert "revenue_min" to "revenue_currency"
        field_name.to_s.gsub(/revenue_(min|max)/, "revenue_currency")
      end

      def currency_options
        [
          ["USD", "$"],
          ["EUR", "€"],
          ["GBP", "£"], 
          ["CAD", "C$"],
          ["AUD", "A$"],
          ["JPY", "¥"],
          ["CHF", "Fr"],
          ["CNY", "¥"],
          ["INR", "₹"],
          ["SEK", "kr"],
          ["NOK", "kr"],
          ["DKK", "kr"]
        ]
      end

      def custom_validation_rules
        {
          currency: true,
          format: "currency_kmb"
        }
      end

      def required?
        @required
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