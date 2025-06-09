# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI range slider component that provides an intuitive way for users to select values from a range.
    # Supports labels, custom min/max values, step intervals, and disabled states.
    #
    # @example Basic range slider
    #   render Components::Preline::RangeSlider.new(
    #     name: "volume",
    #     value: 50
    #   )
    #
    # @example Range slider with label and custom range
    #   render Components::Preline::RangeSlider.new(
    #     name: "price",
    #     label: "Price Range",
    #     min: 0,
    #     max: 1000,
    #     step: 10,
    #     value: 250
    #   )
    #
    # @example Disabled range slider
    #   render Components::Preline::RangeSlider.new(
    #     name: "locked_value",
    #     value: 75,
    #     disabled: true,
    #     label: "Locked Setting"
    #   )
    #
    # @example Range slider with custom styling
    #   render Components::Preline::RangeSlider.new(
    #     name: "brightness",
    #     value: 80,
    #     class: "custom-slider",
    #     data: { controller: "brightness-control" }
    #   )
    class RangeSlider < ::Components::Preline::PrelineComponent
      # Initialize a new RangeSlider component
      #
      # @param name [String] The input name attribute (required)
      # @param min [Integer] Minimum value for the range (default: 0)
      # @param max [Integer] Maximum value for the range (default: 100)
      # @param step [Integer] Step interval between values (default: 1)
      # @param value [Integer] Initial/current value (default: 50)
      # @param id [String, nil] Custom HTML id attribute
      # @param label [String, nil] Label text to display above the slider
      # @param disabled [Boolean] Whether the slider is disabled
      # @param class [String] Additional CSS classes
      # @param data [Hash] Data attributes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(name:, **attrs)
        @name = validate_required!(name, 'name')

        # Extract component-specific attributes
        @min = attrs.delete(:min) || 0
        @max = attrs.delete(:max) || 100
        @step = attrs.delete(:step) || 1
        @value = attrs.delete(:value) || 50
        @label = attrs.delete(:label)
        @disabled = validate_boolean!(attrs.delete(:disabled) || false, 'disabled')

        # Extract id before initialize_component
        @component_id = attrs.delete(:id) || "range_#{name}_#{SecureRandom.hex(4)}"

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        div(class: wrapper_classes) do
          label(for: @component_id, class: label_classes) { @label } if @label

          attrs = {
            type: 'range',
            id: @component_id,
            name: @name,
            min: @min,
            max: @max,
            step: @step,
            value: @value
          }
          attrs[:disabled] = @disabled if @disabled

          input_attrs = component_attributes(additional_classes: slider_classes, additional_attrs: attrs)

          input(**input_attrs)

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        'hs-range-slider-wrapper'
      end

      def label_classes
        'block text-sm font-medium mb-2'
      end

      def slider_classes
        'hs-range-slider w-full bg-gray-200 rounded-lg appearance-none cursor-pointer'
      end
    end
  end
end
