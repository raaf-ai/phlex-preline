# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI number input component with increment/decrement buttons.
    # Provides an enhanced number input experience with visual controls for adjusting values.
    #
    # @example Basic number input
    #   render Components::Preline::InputNumber.new(
    #     name: "quantity",
    #     value: 1
    #   )
    #
    # @example Number input with constraints
    #   render Components::Preline::InputNumber.new(
    #     name: "age",
    #     label: "Your Age",
    #     min: 18,
    #     max: 100,
    #     value: 25
    #   )
    #
    # @example Number input with step and label
    #   render Components::Preline::InputNumber.new(
    #     name: "price",
    #     label: "Price ($)",
    #     min: 0,
    #     step: 0.01,
    #     value: 9.99
    #   )
    #
    # @example Disabled number input
    #   render Components::Preline::InputNumber.new(
    #     name: "fixed_value",
    #     value: 10,
    #     disabled: true,
    #     label: "Fixed Quantity"
    #   )
    #
    # @example Read-only number input
    #   render Components::Preline::InputNumber.new(
    #     name: "calculated_total",
    #     value: 150,
    #     readonly: true,
    #     label: "Total (calculated)"
    #   )
    class InputNumber < ::Components::Preline::PrelineComponent
      # Initialize a new InputNumber component
      #
      # @param name [String] The input name attribute (required)
      # @param value [Integer, Float] Initial/current value (default: 0)
      # @param min [Integer, Float, nil] Minimum allowed value
      # @param max [Integer, Float, nil] Maximum allowed value
      # @param step [Integer, Float] Step interval for increments (default: 1)
      # @param id [String, nil] Custom HTML id attribute
      # @param label [String, nil] Label text to display above the input
      # @param disabled [Boolean] Whether the input is disabled
      # @param readonly [Boolean] Whether the input is read-only
      # @param class [String] Additional CSS classes
      # @param data [Hash] Data attributes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(name:, **attrs)
        @name = validate_required!(name, 'name')

        # Extract component-specific attributes
        @value = attrs.delete(:value) || 0
        @min = attrs.delete(:min)
        @max = attrs.delete(:max)
        @step = attrs.delete(:step) || 1
        @label = attrs.delete(:label)
        @disabled = validate_boolean!(attrs.delete(:disabled) || false, 'disabled')
        @readonly = validate_boolean!(attrs.delete(:readonly) || false, 'readonly')

        # Extract id before initialize_component
        @component_id = attrs.delete(:id) || "input_number_#{name}_#{SecureRandom.hex(4)}"

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        div(class: wrapper_classes) do
          label(for: @component_id, class: label_classes) { @label } if @label

          div(class: 'hs-input-number', data: { 'hs-input-number': '' }) do
            div(class: 'flex') do
              button(
                type: 'button',
                class: button_classes(:decrement),
                data: { 'hs-input-number-decrement': '' },
                disabled: @disabled || @readonly
              ) do
                minus_icon
              end

              attrs = {
                type: 'number',
                id: @component_id,
                name: @name,
                value: @value,
                min: @min,
                max: @max,
                step: @step,
                'data-hs-input-number-input': ''
              }
              attrs[:disabled] = @disabled if @disabled
              attrs[:readonly] = @readonly if @readonly

              input_attrs = component_attributes(additional_classes: input_classes, additional_attrs: attrs)

              input(**input_attrs)

              button(
                type: 'button',
                class: button_classes(:increment),
                data: { 'hs-input-number-increment': '' },
                disabled: @disabled || @readonly
              ) do
                plus_icon
              end
            end
          end

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        'hs-input-number-wrapper'
      end

      def label_classes
        'block text-sm font-medium text-gray-700 mb-2'
      end

      def input_classes
        'hs-input-number-field text-center w-20 py-2 px-3 block border-gray-200 text-gray-800'
      end

      def button_classes(type)
        base = 'size-10 inline-flex justify-center items-center gap-x-2 text-sm font-medium border border-gray-200 text-gray-800 hover:bg-gray-50 disabled:opacity-50 disabled:pointer-events-none'

        position = type == :decrement ? 'rounded-s-lg' : 'rounded-e-lg'

        [base, position].compact.join(' ')
      end

      def minus_icon
        svg(
          class: 'size-4',
          xmlns: 'http://www.w3.org/2000/svg',
          width: '24',
          height: '24',
          viewBox: '0 0 24 24',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          stroke_linecap: 'round',
          stroke_linejoin: 'round'
        ) do |s|
          s.path(d: 'M5 12h14')
        end
      end

      def plus_icon
        svg(
          class: 'size-4',
          xmlns: 'http://www.w3.org/2000/svg',
          width: '24',
          height: '24',
          viewBox: '0 0 24 24',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          stroke_linecap: 'round',
          stroke_linejoin: 'round'
        ) do |s|
          s.path(d: 'M5 12h14')
          s.path(d: 'M12 5v14')
        end
      end
    end
  end
end
